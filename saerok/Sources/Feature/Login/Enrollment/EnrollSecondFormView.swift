//
//  EnrollSecondFormView.swift
//  saerok
//
//  Created by HanSeung on 5/19/25.
//


import SwiftUI

extension EnrollView {
    struct EnrollSecondFormView: View {
        @FocusState var isFocused: Bool
        @Binding var currentStep: Step
        @Binding var user: User
        @Environment(\.modelContext) var context
        
        var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Constants.formItemSpacing) {
                        genderSelection
                        Group {
                            DateFormView(title: "생년월일(선택)", date: $user.birthDate)
                            DateFormView(title: "탐조 입문 시기(선택)", date: $user.startBirdingDate)
                        }
                        .padding(.horizontal, Constants.horizontalPadding)
                    }
                }
                
                Spacer()
                
                VStack(spacing: Constants.buttonVerticalSpacing) {
                    Button(action: nextButtonTapped) {
                        Text("다음")
                            .frame(height: Constants.buttonHeight)
                    }
                    .buttonStyle(.primary)
                    
                    Button(action: passButtonTapped) {
                        Text("건너뛰기")
                            .frame(height: Constants.buttonHeight)
                    }
                    .buttonStyle(.secondary)
                }
            }
        }

        // MARK: - Subviews

        private var genderSelection: some View {
            HStack(spacing: Constants.genderButtonSpacing) {
                Text("성별(선택)")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)
                Spacer()
                genderButton(label: "여성", value: .female)
                genderButton(label: "남성", value: .male)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.trailing, 11)
        }

        private func genderButton(label: String, value: User.Gender) -> some View {
            Button(action: { user.gender = value }) {
                HStack(spacing: Constants.radioSpacing) {
                    Image(user.gender == value ? .radioSelected : .radio)
                    Text(label)
                        .font(.SRFontSet.body0)
                }
            }
        }

        // MARK: - Button Actions

        // TODO: 회원가입API
        private func nextButtonTapped() {
            withAnimation(.smooth) {
                context.insert(user)
                try? context.save()
            }
        }

        private func passButtonTapped() {
            context.insert(user)
        }
    }
}

// MARK: - Constants

private extension EnrollView.Constants {
    static let horizontalPadding: CGFloat = 4
    static let radioSpacing: CGFloat = 8
    static let genderButtonSpacing: CGFloat = 34
    static let formItemSpacing: CGFloat = 20
    static let buttonHeight: CGFloat = 32
    static let buttonVerticalSpacing: CGFloat = 15
}
