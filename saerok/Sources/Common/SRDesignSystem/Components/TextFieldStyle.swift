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
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(
                isFocused.wrappedValue ? .white : .gray
            )
            .clipShape(Capsule(style: .circular))
            .overlay(
                isFocused.wrappedValue ? RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth:2) : nil
            )
    }
}
