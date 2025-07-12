//
//  EditNicknameView.swift
//  saerok
//
//  Created by HanSeung on 6/12/25.
//

import SwiftData
import SwiftUI

struct EditNicknameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.injected) var injected
    
    @Binding var path: NavigationPath
    
    @ObservedObject var userManager = UserManager.shared
    private var user: User? { userManager.user }
    
    @State private var nicknameStatus: NicknameStatus = .empty
    @FocusState private var isFocused: Bool
    @State private var nickname: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            navigationBar
            Group {
                nicknameSection
                Spacer()
                saveButton
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        .regainSwipeBack()
        .onChange(of: nickname) { _, newValue in
            updateNicknameStatus(newValue)
        }
    }
    
    private var navigationBar: some View {
        NavigationBar(
            center: {
                Text("닉네임 변경하기")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    path.removeLast()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
            })
    }
    
    private var nicknameSection: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                nicknameTextField
                nicknameCheckButton
            }
            
            errorSection
                .font(.SRFontSet.caption1)
                .padding(.horizontal, 10)
            Spacer()
            
        }
        .frame(maxWidth: .infinity)
    }
    
    private var nicknameTextField: some View {
        TextField("사용할 닉네임을 입력해주세요.", text: $nickname)
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .srStyled(.textField(isFocused: $isFocused))
            .frame(maxWidth: .infinity)
    }
    
    private var nicknameCheckButton: some View {
        Button(action: nicknameCheckButtonTapped) {
            Text("중복확인")
                .padding(.vertical, 2)
        }
        .font(.SRFontSet.button3)
        .disabled(nicknameStatus != .notChecked)
        .frame(width: 83)
        .buttonStyle(.confirm)
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
    
    private var saveButton: some View {
        Button(action: saveButtonTapped) {
            Text("닉네임 변경하기")
        }
        .buttonStyle(.primary)
        .disabled(nicknameStatus != .available)
    }
    
    private func nicknameCheckButtonTapped() {
        Task {
            nicknameStatus = .checking
            do {
                nicknameStatus = .notChecked
                
                let result: DTO.CheckNicknameResponse = try await injected.networkService.performSRRequest(.checkNickname(nickname))

                nicknameStatus = result.isAvailable ? .available : .notAvailable(result.reason ?? "")
            } catch {
                nicknameStatus = .invalid("네트워크 오류가 발생했어요")
                print(error)
            }
        }
    }
    
    private func saveButtonTapped() {
        Task {
            do {
                try await UserManager.shared.updateNickname(to: nickname, networkService: injected.networkService)
                path.removeLast()
            } catch {
                nicknameStatus = .invalid("닉네임 변경에 실패했어요.")
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

#Preview {
    @Previewable @State var path = NavigationPath()
    EditNicknameView(path: $path)
}
