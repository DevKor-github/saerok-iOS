//
//  TextFieldDeletable.swift
//  saerok
//
//  Created by HanSeung on 4/19/25.
//


import SwiftUI

extension View {
    func textFieldDeletable(text: Binding<String>) -> some View {
        self.modifier(TextFieldDeletable(text: text))
    }
}

struct TextFieldDeletable: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
            .overlay {
                HStack {
                    Spacer()
                    Button {
                        $text.wrappedValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.border)
                    }
                }
                .padding(.horizontal, 12)
                .opacity($text.wrappedValue.isEmpty ? 0 : 1)
            }
    }
}
