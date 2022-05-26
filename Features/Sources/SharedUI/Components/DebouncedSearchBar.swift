//
//  SwiftUIView.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import SwiftUI
import SwiftUIX

public struct DebouncedSearchBar: View {
    @StateObject private var textObserver = FieldObserver()
    
    @Binding var debouncedText: String
    @Binding var isFocused: Bool
    
    var disableAutoCorrect = true
    
    public init(debouncedText: Binding<String>, isFocused: Binding<Bool>) {
        _debouncedText = debouncedText
        _isFocused = isFocused
    }
    
    public var body: some View {
        VStack {
            SearchBar("Title", text: $textObserver.searchText, isEditing: $isFocused)
                .disableAutocorrection(disableAutoCorrect)
        }.onReceive(textObserver.$debouncedText) { (val) in
            debouncedText = val
        }
    }
}
