//
//  TextFieldStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import SwiftUI

struct SRTextFieldStyle: ViewModifier {
    var isFocused: FocusState<Bool>.Binding
    
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .focused(isFocused)
            .background(.srWhite)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused.wrappedValue ? Color.main : .border, lineWidth:2)
            )
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    @Previewable @State var text = ""
    @Previewable @State var password: String = ""

    VStack {
        TextField(text: $text, label: {
            
        })
        .srStyled(.textField(isFocused: $isFocused))
        .textFieldDeletable(text: $text)
        

        PasswordField(password: $password)
            .srStyled(.textField(isFocused: $isFocused))
    }
    .padding()
}
