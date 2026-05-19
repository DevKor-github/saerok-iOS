//
//  EnrollSubmittedView.swift
//  saerok
//
//  Created by HanSeung on 5/19/25.
//

import SwiftUI

extension EnrollView {
    struct EnrollSubmittedView: View {
        let onStart: () -> Void

        var body: some View {
            VStack(alignment: .leading) {
                NavigationBar()
                Group {
                    Image(.saerokLogo)
                        .resizable()
                        .frame(width: 103, height: 52.5)
                    Text("회원가입이 완료됐어요🎉")
                        .font(.SRFontSet.headline1)
                }
                Spacer()
                Button(action: startButtonTapped) {
                    Text("새록 시작하기")
                }
                .srStyled(.primaryButton)
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        
        // MARK: - Button Actions

        private func startButtonTapped() {
            withAnimation(.easeInOut(duration: 2.0)) {
                onStart()
            }
        }
    }
}
