//
//  SwiftUIView.swift
//  
//
//  Created by Stef on 11/05/2022.
//

import SwiftUI

public struct DebouncedTextField: View {
    @Binding var debouncedText : String
    @StateObject private var textObserver = FieldObserver()
    
    public init(debouncedText: Binding<String>) {
        _debouncedText = debouncedText
    }
    
    public var body: some View {
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
    }}

