//
//  CollectionCommentInputBar.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//

import SwiftUI

struct CollectionCommentInputBar: View {
    @Binding var text: String
    var selectedNickname: String?
    let nickname: String
    let onSubmit: () async -> Void
    
    @FocusState var isFocused: Bool
    @State var keyboard: KeyboardObserver

    var isGuest: Bool 
    private var isInputValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
//            LinearGradient(
//                stops: [
//                    Gradient.Stop(color: .white.opacity(0), location: 0.00),
//                    Gradient.Stop(color: .white, location: 1.00),
//                ],
//                startPoint: UnitPoint(x: 0.5, y: 0),
//                endPoint: UnitPoint(x: 0.5, y: 1)
//            )
//            .frame(height: 195)
            
            HStack(alignment: .bottom) {
                TextField(
                    isGuest
                    ? "로그인하고 댓글을 남겨보세요."
                    : placeholderText(),
                    text: $text,
                    axis: .vertical
                )
                .focused($isFocused)
                .font(.SRFontSet.body2)
                .lineLimit(4)
                .padding(.vertical, 16)
                
                Spacer()
                
                Button {
                    Task {
                        await onSubmit()
                        text = .init()
                        isFocused.toggle()
                    }
                } label: {
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
            .background(Color.srWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 23)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.85, green: 0.88, blue: 0.87), lineWidth: 1)
                
            )
            .cornerRadius(23)
            .padding(.horizontal, 9)
            .padding(.top, 19)
            .padding(.bottom, isFocused ? 20 : 40)
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .padding(.bottom, keyboard.keyboardHeight)
        .animation(.smooth(duration: 0.25), value: keyboard.keyboardHeight)
        .disabled(isGuest)
        .onChange(of: selectedNickname) { old, new in
            guard let _ = new else { return }
            isFocused = true
        }
    }
    
    func placeholderText() -> String {
        if let selectedNickname {
            return "\(selectedNickname)에게 답글 남기기"
        } else {
            return "\(nickname)에게 댓글 남기기"
        }
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
