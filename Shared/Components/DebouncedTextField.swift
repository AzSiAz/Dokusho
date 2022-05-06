//
//  DebouncedTextField.swift
//  Dokusho
//
//  Created by Stephan Deumier on 21/04/2022.
//

import Foundation
import SwiftUI
import Combine
import SwiftUIX

class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}

struct TextFieldWithDebounce : View {
    @Binding var debouncedText : String
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
    
        VStack {
            TextField("Enter Something", text: $textObserver.searchText)
                .frame(height: 50)
                .padding(.leading, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.horizontal, 20)
        }.onReceive(textObserver.$debouncedText) { (val) in
            debouncedText = val
        }
    }
}

struct SearchBarWithDebounce: View {
    @Binding var debouncedText: String
    @Binding var isFocused: Bool
    
    var disableAutoCorrect = true
    
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
        VStack {
            SearchBar("Title", text: $textObserver.searchText, isEditing: $isFocused)
                .disableAutocorrection(disableAutoCorrect)
        }.onReceive(textObserver.$debouncedText) { (val) in
            debouncedText = val
        }
    }
}
