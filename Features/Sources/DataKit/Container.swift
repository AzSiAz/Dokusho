//
//  File.swift
//  
//
//  Created by Stephan Deumier on 01/10/2023.
//

import Foundation
import SwiftData
import SwiftUI

struct DokushoModelContainerViewModifier: ViewModifier {
    let container: ModelContainer
    
    init(inMemory: Bool) {
        container = try! ModelContainer(
            for: Schema([]),
            configurations: [
                ModelConfiguration(isStoredInMemoryOnly: inMemory)
            ]
        )
    }
    
    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

extension View {
    public func dokushoModelContainer(inMemory: Bool = false) -> some View {
        modifier(DokushoModelContainerViewModifier(inMemory: inMemory))
    }
}
