//
//  FieldObserver.swift
//
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import Observation

@MainActor
@Observable
public final class FieldObserver {
    public private(set) var debouncedText = ""
    public var searchText = "" {
        didSet { scheduleDebounce() }
    }

    @ObservationIgnored private var debounceTask: Task<Void, Never>?

    public init() {}

    private func scheduleDebounce() {
        debounceTask?.cancel()
        let text = searchText
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self?.debouncedText = text
        }
    }
}
