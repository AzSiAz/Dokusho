//
//  AsyncButton.swift
//  AsyncButton
//
//  Created by Stephan Deumier on 23/07/2021.
//

import SwiftUI

struct AsyncButton<Content: View>: View {
    @State var isActionRunning = false
    
    let action: () async throws -> Void
    let content: Content
    
    init(action: @escaping () async -> Void, @ViewBuilder _ content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            Task {
                self.isActionRunning.toggle()
                try await self.action()
                self.isActionRunning.toggle()
            }
        }) {
            if isActionRunning { ProgressView() }
            else { self.content }
        }
        .disabled(isActionRunning)
        .buttonStyle(.plain)
    }
}
