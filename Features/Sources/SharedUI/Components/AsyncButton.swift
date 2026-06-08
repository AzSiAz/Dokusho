//
//  AsyncButton.swift
//  AsyncButton
//
//  Created by Stephan Deumier on 23/07/2021.
//

import SwiftUI
import OSLog

public struct AsyncButton<Content: View>: View {
    @State var isActionRunning = false
    
    let action: @Sendable () async throws -> Void
    let content: Content
    
    public init(action: @Sendable @escaping () async -> Void, @ViewBuilder _ content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            Task {
                self.isActionRunning = true
                defer { self.isActionRunning = false }
                do {
                    try await self.action()
                } catch {
                    Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dokusho", category: "ui")
                        .error("AsyncButton action failed: \(error)")
                }
            }
        }) {
            if isActionRunning { ProgressView() }
            else { self.content }
        }
        .disabled(isActionRunning)
        .buttonStyle(.plain)
    }
}
