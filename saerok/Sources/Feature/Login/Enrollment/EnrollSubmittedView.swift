//
//  EnrollSubmittedView.swift
//  saerok
//
//  Created by HanSeung on 5/19/25.
//


import SwiftUI

extension EnrollView {
    struct EnrollSubmittedView: View {
        @Environment(\.injected) var injected
        
        var body: some View {
            VStack(alignment: .leading) {
                NavigationBar()
                Group {
                    Text("회원가입이\n완료되었습니다!🎉")
                        .font(.SRFontSet.headline1)
                }
                Spacer()
                Button(action: startButtonTapped) {
                    Text("새록 시작하기")
                        .padding(.vertical, 5)
                }
                .buttonStyle(.primary)
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        
        // MARK: - Button Actions

        private func startButtonTapped() {
            withAnimation(.easeInOut(duration: 2.0)) {
                injected.appState[\.authStatus] = .signedIn(isRegistered: true)
            }
        }
    }
}
