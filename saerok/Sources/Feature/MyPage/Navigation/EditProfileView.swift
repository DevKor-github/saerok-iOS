//
//  EditProfileView.swift
//  saerok
//
//  Created by HanSeung on 6/12/25.
//

import SwiftData
import SwiftUI

extension EditProfileView {
    @Observable
    final class ViewModel {
        private var userManager = UserManager.shared
        private let interactor: UserInteractor
        var user: User? { userManager.user }
        var nicknameStatus: NicknameStatus = .empty

        init(userManager: UserManager = UserManager.shared, interactor: UserInteractor) {
            self.userManager = userManager
            self.interactor = interactor
        }
        
        func checkNicknameAvailability(nickname: String) async {
            nicknameStatus = .checking
            do {
                nicknameStatus = .notChecked
                let result = try await interactor.checkNicknameAvailability(nickname)
                nicknameStatus = result.0 ? .available : .notAvailable(result.1 ?? "")
            } catch {
                nicknameStatus = .invalid("네트워크 오류가 발생했어요")
            }
        }
        
       func saveNickname(nickname: String) async {
            do {
                try await UserManager.shared.updateNickname(to: nickname)
            } catch {
                nicknameStatus = .invalid("닉네임 변경에 실패했어요.")
            }
        }
        
        func updateNicknameStatus(_ nickname: String) {
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
        
        func updateProfileImage(_ uiImage: UIImage) async throws {
            guard let originalData = uiImage.jpegData(compressionQuality: 1.0) else {
                return
            }
            
            let _ = try await interactor.updateProfileImage(originalData)
            await userManager.refreshUser()
        }
        
        func deleteProfileImage() async throws {
            try await interactor.deleteProfileImage()
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    private var viewModel: ViewModel
    
    @FocusState private var isFocused: Bool
    @State private var nickname: String = ""
    @State private var profileImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isLoadingImage = false
    @State private var showOption = false
    @State var imageReloadKey = UUID()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .onChange(of: nickname) { _, newValue in
                viewModel.updateNicknameStatus(nickname)
            }
            .onChange(of: profileImage) { _, newValue in
                updateProfileImage()
            }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 28) {
            navigationBar
            Group {
                profileImageSection
                nicknameSection
                Spacer()
                saveButton
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        .sheet(isPresented: $showOption) {
            VStack(spacing: 36) {
                Spacer()
                Button {
                    showOption.toggle()
                    isShowingImagePicker.toggle()
                } label: {
                    Text("변경하기")
                        .font(.SRFontSet.subtitle3)
                        .bold()
                }
                
                Button {
                    Task {
                        do {
                            try await viewModel.deleteProfileImage()
                            updateProfileImage()
                        } catch { }
                        showOption.toggle()
                    }
                } label: {
                    Text("삭제하기")
                        .font(.SRFontSet.subtitle3)
                        .bold()
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .buttonStyle(.plain)
            .presentationDetents([.fraction(0.2)])
            .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ZStack {
                ImagePicker(image: $profileImage, isLoading: $isLoadingImage)
                    .disabled(isLoadingImage)
                
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("이미지 불러오는 중…")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .opacity(isLoadingImage ? 1 : 0)
                .disabled(true)
            }
        }
        .regainSwipeBack()
    }
    
    private var navigationBar: some View {
        NavigationBar(
            center: {
                Text("프로필 편집")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .srStyled(.borderedIconButton)
            })
    }
    
    private var profileImageSection: some View {
        VStack(alignment: .center, spacing: 12) {
            ReactiveAsyncImage(
                url: viewModel.user?.imageURL ?? "",
                scale: .small,
                size: .init(width: 100, height: 100),
                downsampling: true
            )
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 1.4)
                    .stroke(.srLightGray, lineWidth: 3)
            )
            .overlay {
                Button {
                    showOption = true
                } label: {
                    Image.SRIconSet.edit
                        .frame(.defaultIconSizeLarge)
                }
                .srStyled(.iconButton)
                .overlay(
                    Circle()
                        .inset(by: 0.5)
                        .stroke(.srLightGray, lineWidth: 1)
                )
                .offset(x: 35, y: 35)
            }
        }
        .frame(maxWidth: .infinity)
        .id(imageReloadKey)
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
        TextField("\(viewModel.user?.nickname ?? "사용할 닉네임을 입력해주세요.")", text: $nickname)
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
        .disabled(viewModel.nicknameStatus != .notChecked)
        .frame(width: 83)
        .srStyled(.alert(.confirm))
    }
    
    @ViewBuilder
    private var errorSection: some View {
        switch viewModel.nicknameStatus {
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
            Text("닉네임 수정하기")
        }
        .srStyled(.primaryButton)
        .disabled(viewModel.nicknameStatus != .available)
        .padding(.bottom, 16)
    }
    
    private func nicknameCheckButtonTapped() {
        Task {
            await viewModel.checkNicknameAvailability(nickname: nickname)
        }
    }
    
    private func saveButtonTapped() {
        Task {
            await viewModel.saveNickname(nickname: nickname)
            coordinator.pop()
        }
    }
    
    private func updateProfileImage() {
        if let image = profileImage {
            Task {
                do {
                    try await viewModel.updateProfileImage(image)
                    imageReloadKey = UUID()
                } catch { }
            }
        }
    }
}
