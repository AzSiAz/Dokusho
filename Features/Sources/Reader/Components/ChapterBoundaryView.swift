//
//  ChapterBoundaryView.swift
//  Dokusho (iOS)
//
//  Created by Claude on 2026.
//

import SwiftUI
import DataKit

enum ChapterBoundaryType: Equatable {
    case previous(chapter: MangaChapter)
    case next(chapter: MangaChapter)
    case startOfBook
    case endOfBook
}

struct ChapterBoundaryView: View {
    let boundaryType: ChapterBoundaryType
    let isLoading: Bool
    let error: Error?
    let onRetry: (() -> Void)?

    init(
        boundaryType: ChapterBoundaryType,
        isLoading: Bool = false,
        error: Error? = nil,
        onRetry: (() -> Void)? = nil
    ) {
        self.boundaryType = boundaryType
        self.isLoading = isLoading
        self.error = error
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Icon
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            // Subtitle (chapter name)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Loading indicator
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())

                    Text("Loading chapter...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }

            // Error state with retry
            if error != nil, !isLoading {
                VStack(spacing: 8) {
                    Text("Failed to load chapter")
                        .font(.caption)
                        .foregroundColor(.red)

                    if let onRetry = onRetry {
                        Button(action: onRetry) {
                            Label("Retry", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            // Hint text
            if !isLoading && error == nil && hasHint {
                Text(hintText)
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
                    .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    private var iconName: String {
        switch boundaryType {
        case .previous: return "arrow.up.circle"
        case .next: return "arrow.down.circle"
        case .startOfBook: return "book.closed"
        case .endOfBook: return "checkmark.circle"
        }
    }

    private var title: String {
        switch boundaryType {
        case .previous: return "Previous Chapter"
        case .next: return "Next Chapter"
        case .startOfBook: return "Beginning of Manga"
        case .endOfBook: return "End of Manga"
        }
    }

    private var subtitle: String? {
        switch boundaryType {
        case .previous(let chapter): return chapter.title
        case .next(let chapter): return chapter.title
        case .startOfBook: return "You're at the first chapter"
        case .endOfBook: return "You've finished reading!"
        }
    }

    private var hasHint: Bool {
        switch boundaryType {
        case .previous, .next: return true
        case .startOfBook, .endOfBook: return false
        }
    }

    private var hintText: String {
        switch boundaryType {
        case .previous, .next: return "Continue scrolling to load"
        case .startOfBook, .endOfBook: return ""
        }
    }
}
