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
    
    @Binding private var user: User
    @Query private var users: [User]
    
    @State private var authStatus: AppState.AuthStatus = .notDetermined
    var authStatusUpdate: AnyPublisher<AppState.AuthStatus, Never> {
        injected.appState.updates(for: \.authStatus)
    }
    
    init(_ user: Binding<User>) {
        self._user = user
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
            KakaoLogin(user: $user)
            continueWithoutLoginButton
        }
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .padding(.bottom, Constants.bottomPadding)
        .ignoresSafeArea(.all)
    }
    
    var continueWithoutLoginButton: some View {
        Button(action: {
            injected.appState[\.authStatus] = .guest
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

#Preview {
    //    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //    appDelegate.rootView
}
