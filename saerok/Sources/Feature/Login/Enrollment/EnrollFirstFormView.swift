//
//  EnrollFirstFormView.swift
//  saerok
//
//  Created by HanSeung on 5/19/25.
//


import SwiftData
import SwiftUI

extension EnrollView {
    struct EnrollFirstFormView: View {
        enum NicknameStatus: Equatable {
            case empty
            case invalid(String)
            case notChecked
            case checking
            case available
            case notAvailable(String)
        }
        
        @Environment(\.injected) var injected
        @Environment(\.modelContext) var modelContext
        
        @State private var nicknameStatus: NicknameStatus = .empty
        @FocusState private var isFocused: Bool
        @Binding var currentStep: Step
        @Binding var user: User
        
        var body: some View {
            ZStack {
                nicknameSection
                nextButtonSection
            }
            .onChange(of: user.nickname) { _, newValue in
                updateNicknameStatus(newValue)
            }
        }
        
        // MARK: - Subviews
        
        private var nicknameSection: some View {
            VStack(alignment: .leading, spacing: 7) {
                Text("닉네임 입력(필수)")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, Constants.horizontalTextPadding)
                
                HStack {
                    TextField("사용할 닉네임을 입력해주세요.", text: $user.nickname)
                    Spacer()
                    nicknameCheckButton
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .srStyled(.textField(isFocused: $isFocused))
    
                errorSection
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, Constants.horizontalTextPadding)
                
                Spacer()
            }
            .padding(.horizontal, Constants.fieldHorizontalPadding)
        }
        
        private var nicknameCheckButton: some View {
            Button("중복확인") {
                Task {
                    nicknameStatus = .checking
                    do {
                        let result: DTO.CheckNicknameResponse = try await injected.networkService.performSRRequest(.checkNickname(user.nickname))

                        nicknameStatus = result.isAvailable ? .available : .notAvailable(result.reason ?? "")
                    } catch {
                        nicknameStatus = .invalid("네트워크 오류가 발생했어요")
                        print(error)
                    }
                }
            }
            .font(.SRFontSet.button3)
            .disabled(nicknameStatus != .notChecked)
        }
        
        @ViewBuilder
        private var errorSection: some View {
            switch nicknameStatus {
            case .invalid(let message):
                Text(message).foregroundColor(.red)
                
            case .available:
                Text("사용 가능한 닉네임입니다.").foregroundColor(.splash)
                
            case .notAvailable(let reason):
                Text(reason).foregroundColor(.red)
                
            default:
                EmptyView()
            }
        }
        
        private var nextButtonSection: some View {
            VStack {
                Spacer()
                
                Button(action: nextButtonTapped) {
                    Text("다음")
                        .frame(height: 32)
                }
                .buttonStyle(.primary)
                .disabled(nicknameStatus != .available)
            }
        }
        
        // MARK: - Button Actions
        
        private func nextButtonTapped() {
            Task {
                do {
                    let me: DTO.MeResponse = try await injected.networkService
                        .performSRRequest(.updateMe(nickname: user.nickname))
                    user.nickname = me.nickname
                    user.email = me.email
                    modelContext.insert(user)
                } catch {
                    print("요청 실패: \(error)")
                }
            }
        }
        
        private func updateNicknameStatus(_ nickname: String) {
            let trimmed = nickname.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                nicknameStatus = .empty
                return
            }
            if trimmed.count < 2 {
                nicknameStatus = .invalid("닉네임은 최소 2글자 이상이어야 해요")
                return
            }
            if trimmed.count > 8 {
                nicknameStatus = .invalid("닉네임은 최대 8글자까지 가능해요")
                return
            }
            
            let regex = "^[가-힣a-zA-Z0-9]+$"
            if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed) {
                nicknameStatus = .invalid("닉네임은 한글, 영어, 숫자만 쓸 수 있어요")
                return
            }
            
            nicknameStatus = .notChecked
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

