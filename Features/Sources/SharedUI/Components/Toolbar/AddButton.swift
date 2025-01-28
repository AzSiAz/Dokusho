//
//  AddButton.swift
//  AddButton
//
//  Created by Stephan Deumier on 08/09/2021.
//

import SwiftUI

public struct AddButton: View {
    let onTapGesture: @Sendable () -> Void
    
    public init(onTapGesture: @Sendable @escaping () -> Void) {
        self.onTapGesture = onTapGesture
    }
    
    public var body: some View {
        AsyncButton(action: onTapGesture) {
            Image(systemName: "plus")
        }
    }
}
