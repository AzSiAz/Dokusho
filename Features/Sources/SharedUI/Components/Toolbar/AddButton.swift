//
//  AddButton.swift
//  AddButton
//
//  Created by Stephan Deumier on 08/09/2021.
//

import SwiftUI

public struct AddButton: View {
    let onTapGesture: () -> Void
    
    public init(onTapGesture: @escaping () -> Void) {
        self.onTapGesture = onTapGesture
    }
    
    public var body: some View {
        AsyncButton(action: onTapGesture) {
            Image(systemName: "plus")
        }
    }
}
