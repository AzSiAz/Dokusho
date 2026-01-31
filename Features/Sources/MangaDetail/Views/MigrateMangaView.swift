//
//  MigrateMangaView.swift
//  Dokusho
//
//  Created by Migration Feature
//

import SwiftUI
import DataKit
import MangaScraper
import SharedUI

public struct MigrateMangaView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var vm: MigrateMangaVM

    private let loadError: String?

    public init(manga: Manga, scraper: Scraper) {
        _vm = StateObject(wrappedValue: MigrateMangaVM(manga: manga, scraper: scraper))
        loadError = nil
    }

    /// Initialize from DetailedMangaInList (used from collection page context menu)
    public init(manga: DetailedMangaInList, scraper: Scraper) {
        // Try to fetch full manga from database
        if let fullManga = try? MigrationService.shared.getFullManga(from: manga.manga) {
            _vm = StateObject(wrappedValue: MigrateMangaVM(manga: fullManga, scraper: scraper))
            loadError = nil
        } else {
            // Fallback: create minimal manga (should rarely happen as manga must be in collection)
            let fallbackManga = Manga(
                mangaId: manga.manga.mangaId,
                title: manga.manga.title,
                cover: manga.manga.cover,
                synopsis: ""
            )
            _vm = StateObject(wrappedValue: MigrateMangaVM(manga: fallbackManga, scraper: scraper))
            loadError = "Could not load full manga details"
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let error = loadError {
                        Text(error)
                            .foregroundColor(.orange)
                            .padding()
                    }
                    CurrentMangaSection()
                    TargetSourcesSection()
                    MatchResultSection()
                    ChapterMappingSection()
                    MigrationOptionsSection()
                }
                .padding()
            }
            .navigationTitle("Migrate Series")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if vm.isMigrating {
                        ProgressView()
                    } else {
                        Button("Migrate") {
                            Task {
                                do {
                                    _ = try await vm.executeMigration()
                                } catch {
                                    // Error is handled in VM
                                }
                            }
                        }
                        .disabled(!vm.canMigrate)
                    }
                }
            }
            .alert("Migration Complete", isPresented: $vm.migrationComplete) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                if let result = vm.migrationResult {
                    Text("Successfully migrated to \(result.targetSource.name).\n\(result.readStatusTransferred) read chapters transferred.\n\(result.chaptersMissed) chapters could not be matched.")
                }
            }
            .onAppear {
                vm.loadTargetSources()
                vm.loadChapterCounts()
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    func CurrentMangaSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                MangaCard(imageUrl: vm.manga.cover.absoluteString)
                    .frame(width: 80, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.manga.title)
                        .font(.headline)
                        .lineLimit(2)

                    Text("from \(vm.currentScraper.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(vm.readChapterCount)/\(vm.totalChapterCount) chapters read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    func TargetSourcesSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Sources")
                .font(.headline)

            Text("Toggle and reorder to set priority")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(vm.targetSources) { config in
                TargetSourceRow(config: config)
            }
            .onMove { from, to in
                vm.moveTargetSource(from: from, to: to)
            }

            Button(action: {
                Task {
                    await vm.searchForMatch()
                }
            }) {
                HStack {
                    if vm.isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    Text("Search Now")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isSearching || vm.enabledSourceCount == 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    func TargetSourceRow(config: MigrateMangaVM.TargetSourceConfig) -> some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)

            Toggle(isOn: Binding(
                get: { config.isEnabled },
                set: { _ in vm.toggleTargetSource(config.id) }
            )) {
                HStack {
                    Text(config.source.name)
                    Spacer()
                    if config.isEnabled {
                        Text("\(config.priority + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(4)
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    func MatchResultSection() -> some View {
        if let error = vm.error {
            VStack(alignment: .leading, spacing: 8) {
                Label("Error", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundColor(.orange)

                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }

        if let match = vm.selectedMatch, let source = vm.selectedSource {
            VStack(alignment: .leading, spacing: 8) {
                Label("Match Found", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)

                HStack {
                    RemoteImageCacheView(url: match.thumbnailUrl, contentMode: .fill)
                        .frame(width: 50, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(match.title)
                            .font(.subheadline)
                            .lineLimit(2)

                        Text("on \(source.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                NavigationLink(destination: ManualMatchView(vm: vm)) {
                    Text("Change Match")
                        .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    func ChapterMappingSection() -> some View {
        if let preview = vm.chapterPreview {
            VStack(alignment: .leading, spacing: 8) {
                Text("Chapter Mapping Preview")
                    .font(.headline)

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(preview.matchedCount) chapters matched")
                }
                .font(.subheadline)

                if preview.unmatchedSourceCount > 0 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("\(preview.unmatchedSourceCount) read chapters not found")
                    }
                    .font(.subheadline)
                }

                if preview.unmatchedTargetCount > 0 {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("\(preview.unmatchedTargetCount) new chapters available")
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    func MigrationOptionsSection() -> some View {
        if vm.hasMatch {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $vm.deleteOriginal) {
                    VStack(alignment: .leading) {
                        Text("Delete original after migration")
                        Text("Removes the manga from \(vm.currentScraper.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Manual Match View

struct ManualMatchView: View {
    @ObservedObject var vm: MigrateMangaVM
    @Environment(\.dismiss) var dismiss

    @State private var selectedSourceIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Source picker
            Picker("Source", selection: $selectedSourceIndex) {
                ForEach(Array(vm.targetSources.enumerated()), id: \.offset) { index, config in
                    Text(config.source.name).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Search bar
            HStack {
                TextField("Search title", text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    Task {
                        let source = vm.targetSources[selectedSourceIndex].source
                        await vm.manualSearch(on: source)
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .disabled(vm.isSearching)
            }
            .padding(.horizontal)

            if vm.isSearching {
                Spacer()
                ProgressView()
                Spacer()
            } else if vm.searchResults.isEmpty {
                Spacer()
                Text("No results")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(vm.searchResults) { manga in
                    Button(action: {
                        Task {
                            let source = vm.targetSources[selectedSourceIndex].source
                            await vm.selectMatch(manga, from: source)
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 12) {
                            RemoteImageCacheView(url: manga.thumbnailUrl, contentMode: .fill)
                                .frame(width: 50, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            VStack(alignment: .leading) {
                                Text(manga.title)
                                    .font(.subheadline)
                                    .lineLimit(2)

                                if vm.selectedMatch?.id == manga.id {
                                    Label("Selected", systemImage: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Select Match")
        .navigationBarTitleDisplayMode(.inline)
    }
}
