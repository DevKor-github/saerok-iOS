//
//  LoginView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//

import Combine
import SwiftUI
import SwiftData
import KakaoSDKAuth
import KakaoSDKUser

struct LoginView: View {
    enum Route: Hashable {
        case enroll
    }
    
    @Environment(\.injected) var injected
    @State var showingAlert: Bool = false
    @Binding private var user: User
    @Query private var users: [User]
    @Binding private var authStatus: AppState.AuthStatus
    var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appState.updates(for: \.authStatus)
    }
    
    init(_ user: Binding<User>, authStatus: Binding<AppState.AuthStatus>) {
        self._user = user
        self._authStatus = authStatus
    }
    
    var body: some View {
        content
            .onReceive(authStatusUpdate) { authStatus = $0 }
    }
}

// MARK: - Subviews

private extension LoginView {
    @ViewBuilder
    var content: some View {
        switch authStatus {
        case .notDetermined:
            loginView
        case .signedIn:
            if users.isEmpty {
                EnrollView(user: $user)
            } else {
                EnrollView.EnrollSubmittedView()
            }
        default:
            EmptyView()
        }
    }
    
    var loginView: some View {
        ZStack(alignment: .center) {
            logo
            loginButtonSection
        }
        .customPopup(isPresented: $showingAlert) { alertView }
    }
    
    var alertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "로그인 없이 이용하시겠어요?",
            message: "도감과 지도만 열람할 수 있어요!",
            leading: .init(
                title: "취소",
                action: {
                    showingAlert = false
                },
                style: .bordered
            ),
            trailing: .init(
                title: "계속하기",
                action: {
                    showingAlert = false
                    injected.appState[\.authStatus] = .guest
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    var logo: some View {
        Image(.logo)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.logoWidth)
    }
    
    var loginButtonSection: some View {
        VStack {
            Spacer()
            AppleLoginView(user: $user)
//            KakaoLoginView(user: $user)
            continueWithoutLoginButton
        }
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .padding(.bottom, Constants.bottomPadding)
        .ignoresSafeArea(.all)
    }
    
    var continueWithoutLoginButton: some View {
        Button(action: {
            showingAlert = true
        }) {
            Text("로그인 없이 이용하기")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Constants

private extension LoginView {
    enum Constants {
        static let logoWidth: CGFloat = 103
        static let bottomPadding: CGFloat = 42
    }
}
