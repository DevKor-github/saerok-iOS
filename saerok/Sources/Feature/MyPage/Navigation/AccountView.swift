//
//  AccountView.swift
//  saerok
//
//  Created by HanSeung on 5/29/25.
//

import SwiftData
import SwiftUI
import KakaoSDKUser

extension AccountView {
    @Observable
    final class ViewModel {
        private let appState: Store<AppState>
        private let interactor: UserInteractor
        private let tokenManager: TokenManager

        private(set) var user: AppState.UserProfile?

        init(appState: Store<AppState>, interactor: UserInteractor) {
            self.appState = appState
            self.interactor = interactor
            self.tokenManager = .shared
            self.user = appState[\.currentUser]
        }

        func logout() async throws {
            await tokenManager.clearTokens()
            try await interactor.deleteUser()
            Task { @MainActor in
                appState[\.authStatus] = .notDetermined
            }
        }

        func deleteAccount() async throws {
            try await interactor.deleteAccount()
            appState[\.authStatus] = .notDetermined
        }
    }
}

struct AccountView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
        
    @State private var viewModel: ViewModel
    
    @State private var activePopup: ActivePopup = .none
    @State private var showPopup: Bool = false
    
    @State private var isDeleting: Bool = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            navigationBar
            
            Group {
                userInfoSection
                VStack(spacing: 16) {
                    logoutRow
                    deleteAccountRow
                }
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            
            Spacer()
        }
        .regainSwipeBack()
        .srPopup(
            isPresented: Binding(
                get: { activePopup != .none },
                set: { newValue in
                    if !newValue {
                        activePopup = .none
                    }
                }
            ),
            config: currentPopupConfig
        )
        .disabled(isDeleting)
    }
    
    @ViewBuilder
    private var userInfoSection: some View {
        if let user = viewModel.user {
            VStack(spacing: 28) {
                HStack {
                    Text("연결된 소셜로그인 계정")
                    Spacer()
                    Text(user.email)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("가입일자")
                    Spacer()
                    Text(user.joinedDate.toFullString)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.SRFontSet.body2)
        }
    }
    
    private var logoutRow: some View {
        Button {
            activePopup = .logoutConfirm
        } label: {
            HStack(spacing: 8) {
                Image.SRIconSet.logout
                    .frame(.custom(width: 19, height: 20))
                    .foregroundStyle(.black)
                    .padding(2)
                Text("로그아웃")
                    .font(.SRFontSet.body2)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 15)
            .background(Color.srLightGray)
            .cornerRadius(.infinity)
        }
        .buttonStyle(.plain)
    }
    
    private var deleteAccountRow: some View {
        Button {
            activePopup = .deleteAccountConfirm
        } label: {
            HStack(spacing: 8) {
                Image.SRIconSet.logout
                    .frame(.custom(width: 19, height: 20), tintColor: .red)
                    .foregroundStyle(.black)
                    .padding(2)
                Text("회원탈퇴")
                    .font(.SRFontSet.body2)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 15)
            .background(Color.srLightGray)
            .cornerRadius(.infinity)
        }
        .buttonStyle(.plain)
    }
    
    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("내 계정 관리")
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

    func logout() {        
        Task { @MainActor in
            try await viewModel.logout()
        }
    }
    
    func deleteAccount() {
        Task {
            isDeleting = true
            try await viewModel.deleteAccount()
            showPopup = false
            isDeleting = false
        }
    }
}

private extension AccountView {
    enum ActivePopup {
        case none
        case logoutConfirm
        case deleteAccountConfirm
    }
    
    var currentPopupConfig: PopupConfig? {
        switch activePopup {
        case .logoutConfirm:
            logoutConfirmPopupConfig
        case .deleteAccountConfirm:
            deleteAccountConfirmPopupConfig
        case .none:
            nil
        }
    }
    
    var logoutConfirmPopupConfig: PopupConfig {
        PopupConfig(
            title: "정말 로그아웃 하시겠어요?",
            message: "",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .bordered,
                    action: {
                        activePopup = .none
                    }
                ),
                .init(
                    title: "로그아웃",
                    style: .confirm,
                    action: {
                        activePopup = .none
                        logout()
                    }
                )
            )
        )
    }
    
    var deleteAccountConfirmPopupConfig: PopupConfig {
        PopupConfig(
            title: "정말 탈퇴하시겠어요?",
            message: "탈퇴 시 탐조기록이 모두 삭제돼요",
            buttons: .double(
                .init(
                    title: "회원탈퇴",
                    style: .delete,
                    action: {
                        activePopup = .none
                        deleteAccount()
                    }
                ),
                .init(
                    title: "돌아가기",
                    style: .confirm,
                    action: {
                        activePopup = .none
                    }
                )
            )
        )
    }
}
