//
//  AddButton.swift
//  AddButton
//
//  Created by Stephan Deumier on 08/09/2021.
//

import SwiftUI

struct AddButton: View {
    let onTapGesture: () -> Void
    
    var body: some View {
        AsyncButton(action: onTapGesture) {
            Image(systemSymbol: .plus)
        }
    }
}
