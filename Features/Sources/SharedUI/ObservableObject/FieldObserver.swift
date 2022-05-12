//
//  FieldObserver.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import Foundation
import SwiftUI
import Combine

public class FieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    public init() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            })
            .store(in: &subscriptions)
    }
}

