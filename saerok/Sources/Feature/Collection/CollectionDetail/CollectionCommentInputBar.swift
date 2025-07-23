//
//  CollectionCommentInputBar.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//


import SwiftUI

struct CollectionCommentInputBar: View {
    @Environment(\.injected) var injected
    @Binding var text: String
    @FocusState var isFocused: Bool
    let nickname: String
    let onSubmit: () -> Void
    @ObservedObject var keyboard: KeyboardObserver

    private var isGuest: Bool { injected.appState[\.authStatus] == .guest }
    private var isInputValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 1)

            HStack(alignment: .bottom) {
                TextField(isGuest ? "로그인하고 댓글을 남겨보세요." : "\(nickname)에게 댓글 남기기", text: $text, axis: .vertical)
                    .focused($isFocused)
                    .font(.SRFontSet.body2)
                    .lineLimit(4)
                    .padding(.vertical, 16)
                
                Spacer()
                
                Button(action: {
                    onSubmit()
                }) {
                    Image.SRIconSet.upperArrow
                        .frame(.defaultIconSizeLarge)
                        .padding(8)
                        .background(
                            Circle().fill(!isInputValid ? .whiteGray : .splash)
                        )
                }
                .disabled(!isInputValid)
                .padding(5)
            }
            .padding(.leading, 23)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(23)
            .padding(.horizontal, 9)
            .padding(.top, 19)
            .padding(.bottom, isFocused ? 20 : 40)
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .background(.srWhite)
        .padding(.bottom, keyboard.keyboardHeight)
        .animation(.smooth(duration: 0.25), value: keyboard.keyboardHeight)
        .disabled(isGuest)
    }
}

extension View {
    func commentInputOverlay<OverlayContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> OverlayContent
    ) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    content()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.smooth, value: isPresented.wrappedValue)
                }
            },
            alignment: .bottom
        )
    }
}
