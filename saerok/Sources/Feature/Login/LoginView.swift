//
//  LoginView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//

import Combine
import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser

enum LoginRoute: AppRoute {
    case enroll
}

struct LoginView: View {
    typealias Route = LoginRoute

    @Environment(\.injected) var injected
    @State var showingAlert: Bool = false
    @State private var user: User = .init()
    @State private var enrollmentCompleted: Bool = false
    @Binding private var authStatus: AppState.AuthStatus

    var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appStore.updates(for: \.authStatus)
    }

    init(authStatus: Binding<AppState.AuthStatus>) {
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
            if enrollmentCompleted {
                EnrollView.EnrollSubmittedView()
            } else {
                EnrollView(user: $user, onEnrollmentComplete: {
                    enrollmentCompleted = true
                })
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
                        injected.appStore.send(.enterGuestMode)
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
            AppleLoginView(user: $user)
            KakaoLoginView(user: $user)
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
