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
        private let appState: Store<AppState>
        private let interactor: UserInteractor
        private(set) var user: AppState.UserProfile?
        var nicknameStatus: NicknameStatus = .empty

        // MARK: Form State (View에서 이동)
        var nickname: String = ""
        var pendingProfileImage: UIImage?
        var pendingDeleteImage: Bool = false
        var isLoadingImage: Bool = false

        var hasUnsavedChanges: Bool {
            pendingProfileImage != nil || pendingDeleteImage || nicknameStatus == .available || !nickname.isEmpty
        }

        var canSave: Bool {
            let hasImageChange = pendingProfileImage != nil || pendingDeleteImage
            let hasValidNickname = nicknameStatus == .available
            let nicknameIsBlocking = !nickname.isEmpty && !hasValidNickname
            return (hasImageChange || hasValidNickname) && !nicknameIsBlocking
        }

        init(appState: Store<AppState>, interactor: UserInteractor) {
            self.appState = appState
            self.interactor = interactor
            self.user = appState[\.currentUser]
        }

        func checkNicknameAvailability() async {
            nicknameStatus = .checking
            do {
                nicknameStatus = .notChecked
                let result = try await interactor.checkNicknameAvailability(nickname)
                nicknameStatus = result.0 ? .available : .notAvailable(result.1 ?? "")
            } catch {
                nicknameStatus = .invalid("네트워크 오류가 발생했어요")
            }
        }

        func saveNickname() async {
            do {
                try await interactor.updateNickname(nickname)
                let fetched = try await interactor.getUser()
                let profile = AppState.UserProfile(fetched)
                appState[\.currentUser] = profile
                self.user = profile
            } catch {
                nicknameStatus = .invalid("닉네임 변경에 실패했어요.")
            }
        }

        func updateNicknameStatus() {
            let trimmed = nickname.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty { nicknameStatus = .empty; return }
            if trimmed.count < 2 { nicknameStatus = .invalid("닉네임은 최소 2글자 이상이어야 해요"); return }
            if trimmed.count > 8 { nicknameStatus = .invalid("닉네임은 최대 8글자까지 가능해요"); return }

            let regex = "^[가-힣a-zA-Z0-9]+$"
            if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed) {
                nicknameStatus = .invalid("닉네임은 한글, 영어, 숫자만 쓸 수 있어요")
                return
            }

            nicknameStatus = .notChecked
        }

        func updateProfileImage(_ uiImage: UIImage) async throws {
            guard let originalData = uiImage.jpegData(compressionQuality: 1.0) else { return }
            let _ = try await interactor.updateProfileImage(originalData)
            let fetched = try await interactor.getUser()
            let profile = AppState.UserProfile(fetched)
            appState[\.currentUser] = profile
            self.user = profile
        }

        func deleteProfileImage() async throws {
            try await interactor.deleteProfileImage()
            let fetched = try await interactor.getUser()
            let profile = AppState.UserProfile(fetched)
            appState[\.currentUser] = profile
            self.user = profile
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel: ViewModel

    @FocusState private var isFocused: Bool
    @State private var profileImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var showOption = false
    @State private var showUnsavedChangesAlert = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .onChange(of: viewModel.nickname) { _, _ in
                viewModel.updateNicknameStatus()
            }
            .onChange(of: profileImage) { _, newImage in
                guard let newImage else { return }
                viewModel.pendingProfileImage = newImage
                viewModel.pendingDeleteImage = false
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
                    viewModel.pendingDeleteImage = true
                    viewModel.pendingProfileImage = nil
                    profileImage = nil
                    showOption.toggle()
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
                ImagePicker(image: $profileImage, isLoading: $viewModel.isLoadingImage)
                    .disabled(viewModel.isLoadingImage)

                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("이미지 불러오는 중…")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .opacity(viewModel.isLoadingImage ? 1 : 0)
                .disabled(true)
            }
        }
        .regainSwipeBack()
        .srPopup(isPresented: $showUnsavedChangesAlert, config: unsavedChangesPopupConfig)
    }

    private var unsavedChangesPopupConfig: PopupConfig {
        PopupConfig(
            title: "변경사항이 저장되지 않았어요",
            message: "'수정 완료'를 눌러야 변경사항이 저장돼요.",
            buttons: .double(
                PopupButtonConfig(title: "계속 수정하기", style: .confirm) {
                    showUnsavedChangesAlert = false
                },
                PopupButtonConfig(title: "나가기", style: .delete) {
                    coordinator.pop()
                }
            )
        )
    }

    private var navigationBar: some View {
        NavigationBar(
            center: {
                Text("프로필 편집")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    if viewModel.hasUnsavedChanges {
                        showUnsavedChangesAlert = true
                    } else {
                        coordinator.pop()
                    }
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.default)
                }
                .srStyled(.borderedIconButton)
            })
    }

    private var profileImageSection: some View {
        VStack(alignment: .center, spacing: 12) {
            Group {
                if let pendingImage = viewModel.pendingProfileImage {
                    Image(uiImage: pendingImage)
                        .resizable()
                } else {
                    ReactiveAsyncImage(
                        url: viewModel.pendingDeleteImage ? "" : (viewModel.user?.imageURL ?? ""),
                        scale: .small,
                        size: .init(width: 100, height: 100),
                        downsampling: true
                    )
                }
            }
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
                        .frame(.large)
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
        TextField("\(viewModel.user?.nickname ?? "사용할 닉네임을 입력해주세요.")", text: $viewModel.nickname)
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
            Text("수정 완료")
        }
        .srStyled(.primaryButton)
        .disabled(!viewModel.canSave)
        .padding(.bottom, 16)
    }

    private func nicknameCheckButtonTapped() {
        Task {
            await viewModel.checkNicknameAvailability()
        }
    }

    private func saveButtonTapped() {
        Task {
            if viewModel.pendingDeleteImage {
                try? await viewModel.deleteProfileImage()
            } else if let image = viewModel.pendingProfileImage {
                try? await viewModel.updateProfileImage(image)
            }

            if viewModel.nicknameStatus == .available {
                await viewModel.saveNickname()
            }

            coordinator.pop()
        }
    }
}
