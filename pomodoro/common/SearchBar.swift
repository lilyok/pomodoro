//
//  SearchBar.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 21.04.2021.
//

import SwiftUI

struct SearchBar: View {
//    @State var text: String
    private let gapText: String
    @Binding var text: String

    @State private var isEditing = false
        
    init(gapText: String = "Search ..", text: Binding<String>) {
        self.gapText = gapText
        self._text = text
    }

    var body: some View {
        HStack {
            TextField(gapText, text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.isEditing = false
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
                .onChange(of: text) { newValue in
                    if text != "" {
                        self.isEditing = true
                    }
                }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
