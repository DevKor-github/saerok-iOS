//
//  LoginView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//

import SwiftUI

enum LoginRoute: AppRoute {
    case enroll
}

struct LoginView: View {
    typealias Route = LoginRoute

    @State private var showingAlert: Bool = false
    @State private var user: User = .init()
    @State private var enrollmentCompleted: Bool = false
    @Binding private var authStatus: AppState.AuthStatus

    let onSignIn: (Bool) -> Void
    let onEnterGuestMode: () -> Void
    let onRequireAuth: () -> Void

    init(
        authStatus: Binding<AppState.AuthStatus>,
        onSignIn: @escaping (Bool) -> Void,
        onEnterGuestMode: @escaping () -> Void,
        onRequireAuth: @escaping () -> Void
    ) {
        self._authStatus = authStatus
        self.onSignIn = onSignIn
        self.onEnterGuestMode = onEnterGuestMode
        self.onRequireAuth = onRequireAuth
    }

    var body: some View {
        content
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
            if enrollmentCompleted {
                EnrollView.EnrollSubmittedView(onStart: { onSignIn(true) })
            } else {
                EnrollView(user: $user, onEnrollmentComplete: {
                    enrollmentCompleted = true
                }, onBack: onRequireAuth)
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
        .srPopup(isPresented: $showingAlert, config: alertConfig)
    }
    
    var alertConfig: PopupConfig {
        .init(
            title: "로그인 없이 이용하시겠어요?",
            message: "도감과 지도만 열람할 수 있어요!",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .bordered,
                    action: { showingAlert = false }
                ),
                .init(
                    title: "계속하기",
                    style: .confirm,
                    action: {
                        showingAlert = false
                        onEnterGuestMode()
                    }
                )
            )
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
            AppleLoginView(user: $user, onSignIn: onSignIn)
            KakaoLoginView(user: $user, onSignIn: onSignIn)
            continueWithoutLoginButton
        }
        .padding(.horizontal, SRSpacing.screenHorizontal)
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
