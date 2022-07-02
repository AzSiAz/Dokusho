//
//  SwiftUIView.swift
//  
//
//  Created by Stephan Deumier on 30/06/2022.
//

import SwiftUI

struct DebouncingTaskViewModifier<ID: Equatable>: ViewModifier {
    let id: ID
    let priority: TaskPriority
    let nanoseconds: UInt64
    let task: @Sendable () async -> Void
    
    init(
        id: ID,
        priority: TaskPriority = .userInitiated,
        nanoseconds: UInt64 = 0,
        task: @Sendable @escaping () async -> Void
    ) {
        self.id = id
        self.priority = priority
        self.nanoseconds = nanoseconds
        self.task = task
    }
    
    func body(content: Content) -> some View {
        content.task(id: id, priority: priority) {
            do {
                try await Task.sleep(nanoseconds: nanoseconds)
                await task()
            } catch {
                // Ignore cancellation
            }
        }
    }
}

extension View {
    func task<ID: Equatable>(id: ID, priority: TaskPriority = .userInitiated, nanoseconds: UInt64 = 0, task: @Sendable @escaping () async -> Void) -> some View {
        modifier(
            DebouncingTaskViewModifier(
                id: id,
                priority: priority,
                nanoseconds: nanoseconds,
                task: task
            )
        )
    }
}
