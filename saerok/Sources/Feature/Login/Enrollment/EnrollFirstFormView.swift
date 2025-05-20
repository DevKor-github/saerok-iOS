//
//  EnrollFirstFormView.swift
//  saerok
//
//  Created by HanSeung on 5/19/25.
//


import SwiftUI

extension EnrollView {
    struct EnrollFirstFormView: View {
        @FocusState private var isFocused: Bool
        @Binding var currentStep: Step
        @Binding var user: User

        var body: some View {
            ZStack {
                nicknameSection
                nextButtonSection
            }
        }
        
        // MARK: - Subviews

        private var nicknameSection: some View {
            VStack(alignment: .leading) {
                Text("닉네임 입력(필수)")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, Constants.horizontalTextPadding)
                
                TextField("사용할 닉네임을 입력해주세요.", text: $user.nickname)
                    .padding(20)
                    .frame(height: Constants.nicknameFormHeight)
                    .srStyled(.textField(isFocused: $isFocused))
                    .overlay(alignment: .topLeading) {
                        Text("사용 가능한 닉네임입니다.")
                            .font(.SRFontSet.caption1)
                            .foregroundColor(.secondary)
                            .padding(.top, Constants.captionTopPadding)
                            .padding(.leading, Constants.captionLeadingPadding)
                    }
                
                Spacer()
            }
            .padding(.horizontal, Constants.fieldHorizontalPadding)
        }
        
        private var nextButtonSection: some View {
            VStack {
                Spacer()
                
                Button(action: nextButtonTapped) {
                    Text("다음")
                        .frame(height: 32)
                }
                .buttonStyle(.primary)
                .disabled(user.nickname.isEmpty)
            }
        }
        
        // MARK: - Button Actions
        
        private func nextButtonTapped() {
            currentStep = .second
        }
    }
}

// MARK: - Constants

private extension EnrollView.Constants {
    static let nicknameFormHeight: CGFloat = 56
    static let captionTopPadding: CGFloat = 48
    static let captionLeadingPadding: CGFloat = 8
    static let fieldHorizontalPadding: CGFloat = 1
    static let horizontalTextPadding: CGFloat = 10
}
