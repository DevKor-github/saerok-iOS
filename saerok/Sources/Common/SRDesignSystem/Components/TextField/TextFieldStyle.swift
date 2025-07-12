//
//  TextFieldStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import SwiftUI

struct SRTextFieldStyle: ViewModifier {
    var isFocused: FocusState<Bool>.Binding
    let alwaysFocused: Bool
    
    init(isFocused: FocusState<Bool>.Binding, alwaysFocused: Bool = false) {
        self.isFocused = isFocused
        self.alwaysFocused = alwaysFocused
    }
    
    func body(content: Content) -> some View {
        content
            .font(.SRFontSet.body2)
            .autocorrectionDisabled()
            .focused(isFocused)
            .background(.srWhite)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(!alwaysFocused ? (isFocused.wrappedValue ? Color.main : Color.border) : .main, lineWidth:2)
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
