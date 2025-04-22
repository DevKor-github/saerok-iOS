//
//  PasswordField.swift
//  saerok
//
//  Created by HanSeung on 4/19/25.
//


import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @State private var isSecure: Bool = true
    
    private let placeHolder: String = "비밀번호를 입력해주세요."

    var body: some View {
        HStack {
            textField()
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundStyle(.gray)
            }
        }
    }
    
    @ViewBuilder
    func textField() -> some View {
        ZStack {
            SecureField(placeHolder, text: $password)
                .opacity(isSecure ? 1 : 0)
                .allowsHitTesting(isSecure)
            TextField(placeHolder, text: $password)
                .opacity(isSecure ? 0 : 1)
                .allowsHitTesting(!isSecure)
        }
    }
}
