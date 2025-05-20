//
//  LoginView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//

import SwiftUI
import SwiftData
import KakaoSDKAuth
import KakaoSDKUser

struct LoginView: View {
    enum Route: Hashable {
        case enroll
    }
    
    @Binding var isLoggined: Bool
    @State private var path = NavigationPath()
    @State private var user: User = .init()
    @Query private var users: [User]
    
    init(_ isLoggined: Binding<Bool>) {
        self._isLoggined = isLoggined
    }
    
    var body: some View {
        if let _ = users.first, !isLoggined {
            EnrollView.EnrollSubmittedView(isLoggined: $isLoggined)
                .transition(.opacity)
                .animation(.easeInOut, value: isLoggined)
        } else {
            NavigationStack(path: $path) {
                ZStack(alignment: .center) {
                    logo
                    loginButtonSection
                }
                .regainSwipeBack()
                .navigationDestination(for: LoginView.Route.self) { route in
                    switch route {
                    case .enroll:
                        EnrollView(path: $path, user: $user)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

private extension LoginView {
    var logo: some View {
        Image(.logo)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.logoWidth)
    }
    
    var loginButtonSection: some View {
        VStack {
            Spacer()
            KakaoLogin(action: startLoginWithKakaoTalk)
                .padding(.horizontal, SRDesignConstant.defaultPadding)
                .padding(.bottom, Constants.bottomPadding)
        }
        .ignoresSafeArea(.all)
    }
    
    // MARK: - Login Flow
    
    func startLoginWithKakaoTalk() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("❌ Kakao login failed:", error)
                } else if let token = oauthToken {
                    print("✅ Kakao login success")
                    fetchKakaoUserAndEnroll(token: token)
                }
            }
        }
    }
    
    func fetchKakaoUserAndEnroll(token: OAuthToken) {
        UserApi.shared.me { user, error in
            if let error = error {
                print("❌ Failed to fetch Kakao user:", error)
            } else if let kakaoUser = user {
                let id = String(kakaoUser.id ?? 0)
                let name = kakaoUser.kakaoAccount?.name ?? "이름 없음"
                let email = kakaoUser.kakaoAccount?.email ?? "이메일 없음"
                
                Task {
                    await MainActor.run {
                        self.user.id = id
                        self.user.nickname = name
                        self.user.email = email
                    }
                    path.append(Route.enroll)
                }
            }
        }
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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    appDelegate.rootView
}
