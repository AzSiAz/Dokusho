//
//  MassMigrationView.swift
//  Dokusho
//
//  Created by Migration Feature
//

import SwiftUI
import DataKit
import MangaScraper
import SharedUI

public struct MassMigrationView: View {
    @StateObject private var vm = MassMigrationVM()
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        List {
            SourceSelectionSection()
            if vm.selectedSourceId != nil {
                TargetSourcesSection()
                MigrationItemsSection()
                MigrationOptionsSection()
            }
        }
        .navigationTitle("Mass Migration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isMigrating {
                    ProgressView()
                } else if vm.canMigrate {
                    Button("Migrate \(vm.selectedCount)") {
                        Task {
                            await vm.executeSelectedMigrations()
                        }
                    }
                }
            }
        }
        .overlay {
            if vm.isMigrating, let progress = vm.progress {
                MigrationProgressOverlay(progress: progress)
            }
        }
        .onAppear {
            vm.loadSourceScrapers()
        }
    }

    // MARK: - Sections

    @ViewBuilder
    func SourceSelectionSection() -> some View {
        Section {
            if vm.isLoading && vm.sourceScrapers.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if vm.sourceScrapers.isEmpty {
                Text("No sources with manga in collections")
                    .foregroundColor(.secondary)
            } else {
                ForEach(vm.sourceScrapers, id: \.scraper.id) { item in
                    Button(action: {
                        Task {
                            await vm.selectSource(item.scraper.id)
                        }
                    }) {
                        HStack {
                            Text(item.scraper.name)
                            Spacer()
                            Text("\(item.count) series")
                                .foregroundColor(.secondary)
                            if vm.selectedSourceId == item.scraper.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("From Source")
        } footer: {
            Text("Select the source you want to migrate away from")
        }
    }

    @ViewBuilder
    func TargetSourcesSection() -> some View {
        Section {
            ForEach(vm.targetSources) { config in
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
            }
            .onMove { from, to in
                vm.moveTargetSource(from: from, to: to)
            }

            Button(action: {
                Task {
                    await vm.autoMatchAll()
                }
            }) {
                HStack {
                    if vm.isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text("Auto-Match All")
                }
            }
            .disabled(vm.isSearching || vm.enabledSourceCount == 0 || vm.migratableItems.isEmpty)
        } header: {
            Text("Target Sources (by priority)")
        } footer: {
            Text("Toggle and reorder to set search priority")
        }
    }

    @ViewBuilder
    func MigrationItemsSection() -> some View {
        Section {
            if vm.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if vm.migratableItems.isEmpty {
                Text("No manga to migrate")
                    .foregroundColor(.secondary)
            } else {
                // Stats row
                MigrationStatsRow(vm: vm)

                // Selection controls
                HStack {
                    Button("Select All Matched") {
                        vm.selectAll()
                    }
                    .disabled(vm.matchedCount == 0)

                    Spacer()

                    Button("Deselect All") {
                        vm.deselectAll()
                    }
                    .disabled(vm.selectedCount == 0)
                }
                .font(.subheadline)

                // Legend
                HStack(spacing: 16) {
                    Label("Source", systemImage: "square.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Label("Target", systemImage: "square.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)

                ForEach(vm.migratableItems) { item in
                    MigrationItemRow(item: item, vm: vm)
                }
            }
        } header: {
            Text("Migration Preview")
        }
    }

    @ViewBuilder
    func MigrationOptionsSection() -> some View {
        Section {
            Toggle(isOn: $vm.deleteOriginals) {
                VStack(alignment: .leading) {
                    Text("Delete originals after migration")
                    Text("Removes migrated manga from the source")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Options")
        }
    }
}

// MARK: - Migration Stats Row

struct MigrationStatsRow: View {
    @ObservedObject var vm: MassMigrationVM

    var exactMatchCount: Int {
        vm.migratableItems.filter { $0.matchStatus == .matched && $0.matchConfidence == .exact }.count
    }

    var similarMatchCount: Int {
        vm.migratableItems.filter { $0.matchStatus == .matched && $0.matchConfidence == .similar }.count
    }

    var fuzzyMatchCount: Int {
        vm.migratableItems.filter { $0.matchStatus == .matched && $0.matchConfidence == .fuzzy }.count
    }

    var notFoundCount: Int {
        vm.migratableItems.filter { $0.matchStatus == .notFound }.count
    }

    var pendingCount: Int {
        vm.migratableItems.filter { $0.matchStatus == .pending }.count
    }

    var body: some View {
        VStack(spacing: 12) {
            // Match quality breakdown
            if vm.matchedCount > 0 {
                VStack(spacing: 4) {
                    Text("Match Quality")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        StatBadge(
                            count: exactMatchCount,
                            label: "Exact",
                            color: .green,
                            icon: "checkmark.seal.fill"
                        )

                        StatBadge(
                            count: similarMatchCount,
                            label: "Similar",
                            color: .orange,
                            icon: "checkmark.circle"
                        )

                        StatBadge(
                            count: fuzzyMatchCount,
                            label: "Fuzzy",
                            color: .yellow,
                            icon: "questionmark.circle"
                        )
                    }
                }
            }

            // Overall status
            HStack(spacing: 20) {
                StatBadge(
                    count: vm.matchedCount,
                    label: "Matched",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )

                StatBadge(
                    count: notFoundCount,
                    label: "Not Found",
                    color: .red,
                    icon: "xmark.circle.fill"
                )

                StatBadge(
                    count: pendingCount,
                    label: "Pending",
                    color: .secondary,
                    icon: "clock"
                )
            }

            if vm.selectedCount > 0 {
                Text("\(vm.selectedCount) selected for migration")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }

            // Warning for fuzzy matches
            if fuzzyMatchCount > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("\(fuzzyMatchCount) fuzzy match(es) - please verify before migrating")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct StatBadge: View {
    let count: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text("\(count)")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .foregroundColor(color)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Migration Item Row

struct MigrationItemRow: View {
    let item: MassMigrationVM.MigrationItem
    @ObservedObject var vm: MassMigrationVM

    @State private var showManualSearch = false
    @State private var showDetailSheet = false

    private let coverSize: CGFloat = 60
    private let coverHeight: CGFloat = 85

    var confidenceColor: Color {
        switch item.matchConfidence {
        case .exact: return .green
        case .similar: return .orange
        case .fuzzy: return .yellow
        case .none: return .secondary
        }
    }

    var borderColor: Color {
        switch item.matchConfidence {
        case .exact: return .green
        case .similar: return .orange
        case .fuzzy: return .yellow
        case .none: return .secondary
        }
    }

    var body: some View {
        Button(action: {
            if item.matchStatus == .matched {
                showDetailSheet = true
            } else {
                showManualSearch = true
            }
        }) {
            HStack(spacing: 0) {
                // Selection checkbox
                Button(action: {
                    vm.toggleSelection(for: item.id)
                }) {
                    Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(item.isSelected ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(item.matchStatus != .matched)
                .frame(width: 40)

                Spacer(minLength: 4)

                // Source manga (left side)
                VStack(spacing: 4) {
                    RemoteImageCacheView(url: item.manga.cover.absoluteString, contentMode: .fill)
                        .frame(width: coverSize, height: coverHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Text(item.manga.title)
                        .font(.caption2)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: coverSize + 20)
                }

                Spacer(minLength: 8)

                // Arrow and status
                VStack(spacing: 4) {
                    switch item.matchStatus {
                    case .pending:
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("Pending")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                    case .searching:
                        ProgressView()
                        Text("Searching...")
                            .font(.caption2)
                            .foregroundColor(.blue)

                    case .matched:
                        Image(systemName: item.matchConfidence.icon)
                            .font(.title3)
                            .foregroundColor(confidenceColor)
                        VStack(spacing: 1) {
                            Text(item.matchConfidence.displayText)
                                .font(.caption2)
                                .foregroundColor(confidenceColor)
                            if let source = item.matchedSource {
                                Text(source.name)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }

                    case .notFound:
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.red)
                        Text("Not Found")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                .frame(minWidth: 70)

                Spacer(minLength: 8)

                // Target manga (right side) or placeholder
                if let matchedManga = item.matchedManga {
                    VStack(spacing: 4) {
                        RemoteImageCacheView(url: matchedManga.thumbnailUrl, contentMode: .fill)
                            .frame(width: coverSize, height: coverHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(borderColor, lineWidth: 2)
                            )

                        Text(matchedManga.title)
                            .font(.caption2)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: coverSize + 20)
                            .foregroundColor(item.matchConfidence == .exact ? .primary : .secondary)
                    }
                } else {
                    // Placeholder for unmatched
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.tertiarySystemBackground))
                            .frame(width: coverSize, height: coverHeight)
                            .overlay(
                                Image(systemName: item.matchStatus == .notFound ? "questionmark" : "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            )

                        Text(item.matchStatus == .notFound ? "Tap to search" : "...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: coverSize + 20)
                    }
                }

                Spacer(minLength: 4)

                // Action indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showManualSearch) {
            ManualSearchSheet(item: item, vm: vm)
        }
        .sheet(isPresented: $showDetailSheet) {
            MigrationDetailSheet(item: item, vm: vm)
        }
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: MassMigrationVM.MatchStatus

    var body: some View {
        HStack(spacing: 4) {
            statusIcon
            Text(status.displayText)
        }
        .font(.caption)
        .foregroundColor(statusColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(statusColor.opacity(0.1))
        .cornerRadius(4)
    }

    @ViewBuilder
    var statusIcon: some View {
        switch status {
        case .pending:
            Image(systemName: "clock")
        case .searching:
            ProgressView()
                .scaleEffect(0.6)
        case .matched:
            Image(systemName: "checkmark.circle.fill")
        case .notFound:
            Image(systemName: "xmark.circle.fill")
        }
    }

    var statusColor: Color {
        switch status {
        case .pending: return .secondary
        case .searching: return .blue
        case .matched: return .green
        case .notFound: return .red
        }
    }
}

// MARK: - Manual Search Sheet

struct ManualSearchSheet: View {
    let item: MassMigrationVM.MigrationItem
    @ObservedObject var vm: MassMigrationVM
    @Environment(\.dismiss) var dismiss

    @State private var searchQuery: String = ""
    @State private var selectedSourceIndex: Int = 0
    @State private var searchResults: [SourceSmallManga] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Source picker
                if !vm.targetSources.isEmpty {
                    Picker("Source", selection: $selectedSourceIndex) {
                        ForEach(Array(vm.targetSources.enumerated()), id: \.offset) { index, config in
                            Text(config.source.name).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }

                // Search bar
                HStack {
                    TextField("Search title", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)

                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(isSearching)
                }
                .padding(.horizontal)

                if isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if searchResults.isEmpty {
                    Spacer()
                    Text("Search for '\(item.manga.title)'")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(searchResults) { manga in
                        Button(action: {
                            selectMatch(manga)
                        }) {
                            HStack(spacing: 12) {
                                RemoteImageCacheView(url: manga.thumbnailUrl, contentMode: .fill)
                                    .frame(width: 50, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                Text(manga.title)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Search Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                searchQuery = item.manga.title
            }
        }
    }

    func performSearch() {
        guard !vm.targetSources.isEmpty else { return }

        isSearching = true
        let source = vm.targetSources[selectedSourceIndex].source

        Task {
            searchResults = await vm.manualSearch(item: item, on: source, query: searchQuery)
            isSearching = false
        }
    }

    func selectMatch(_ manga: SourceSmallManga) {
        let source = vm.targetSources[selectedSourceIndex].source
        vm.selectMatch(for: item.id, manga: manga, source: source)
        dismiss()
    }
}

// MARK: - Migration Detail Sheet

struct MigrationDetailSheet: View {
    let item: MassMigrationVM.MigrationItem
    @ObservedObject var vm: MassMigrationVM
    @Environment(\.dismiss) var dismiss

    @State private var showManualSearch = false

    var confidenceColor: Color {
        switch item.matchConfidence {
        case .exact: return .green
        case .similar: return .orange
        case .fuzzy: return .yellow
        case .none: return .secondary
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Match confidence badge
                    HStack {
                        Image(systemName: item.matchConfidence.icon)
                        Text(item.matchConfidence.displayText)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(confidenceColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(confidenceColor.opacity(0.15))
                    .cornerRadius(20)

                    // Side by side comparison
                    HStack(alignment: .top, spacing: 16) {
                        // Source manga
                        VStack(spacing: 8) {
                            Text("FROM")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            RemoteImageCacheView(url: item.manga.cover.absoluteString, contentMode: .fill)
                                .frame(width: 120, height: 170)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)

                            Text(item.manga.title)
                                .font(.subheadline.bold())
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .frame(width: 130)
                        }

                        // Arrow
                        VStack {
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(confidenceColor)
                            Spacer()
                        }
                        .frame(height: 170)

                        // Target manga
                        VStack(spacing: 8) {
                            Text("TO")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            if let matchedManga = item.matchedManga {
                                RemoteImageCacheView(url: matchedManga.thumbnailUrl, contentMode: .fill)
                                    .frame(width: 120, height: 170)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(confidenceColor, lineWidth: 3)
                                    )
                                    .shadow(radius: 4)

                                Text(matchedManga.title)
                                    .font(.subheadline.bold())
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                    .frame(width: 130)
                            }
                        }
                    }
                    .padding(.top)

                    // Match analysis
                    if let matchedManga = item.matchedManga {
                        VStack(spacing: 12) {
                            Divider()

                            // Match confidence explanation
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Match Analysis")
                                    .font(.headline)

                                HStack {
                                    Image(systemName: item.matchConfidence.icon)
                                        .foregroundColor(confidenceColor)

                                    switch item.matchConfidence {
                                    case .exact:
                                        Text("Titles match exactly - high confidence")
                                            .foregroundColor(.green)
                                    case .similar:
                                        Text("Titles are similar - medium confidence")
                                            .foregroundColor(.orange)
                                    case .fuzzy:
                                        Text("Best guess based on search - please verify")
                                            .foregroundColor(.yellow)
                                    case .none:
                                        Text("No match information available")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .font(.subheadline)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("Source:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 50, alignment: .leading)
                                        Text(item.manga.title)
                                            .font(.caption)
                                    }
                                    HStack(alignment: .top) {
                                        Text("Target:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 50, alignment: .leading)
                                        Text(matchedManga.title)
                                            .font(.caption)
                                    }
                                }
                                .padding(10)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Target source info
                            if let source = item.matchedSource {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Target Source")
                                        .font(.headline)

                                    HStack {
                                        Image(systemName: "server.rack")
                                            .foregroundColor(.accentColor)
                                        Text(source.name)
                                            .font(.subheadline)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()

                    // Actions
                    VStack(spacing: 12) {
                        // Selection toggle
                        Toggle(isOn: Binding(
                            get: { item.isSelected },
                            set: { _ in vm.toggleSelection(for: item.id) }
                        )) {
                            Label("Include in migration", systemImage: "checkmark.circle")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))

                        Button(action: {
                            showManualSearch = true
                        }) {
                            Label("Change Match", systemImage: "magnifyingglass")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Migration Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showManualSearch) {
                ManualSearchSheet(item: item, vm: vm)
            }
        }
    }
}

// MARK: - Progress Overlay

struct MigrationProgressOverlay: View {
    let progress: MassMigrationVM.MigrationProgress

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress.percentComplete, total: 100)
                .progressViewStyle(LinearProgressViewStyle())

            Text("Migrating \(progress.completed + progress.failed + 1) of \(progress.total)")
                .font(.headline)

            if let title = progress.currentTitle {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 20) {
                Label("\(progress.completed)", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Label("\(progress.failed)", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .font(.subheadline)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(40)
    }
}
