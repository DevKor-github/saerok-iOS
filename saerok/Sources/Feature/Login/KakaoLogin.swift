//
//  KakaoLogin.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI
import KakaoSDKUser
import KakaoSDKAuth

struct KakaoLogin: View {
    @Binding var user: User
    @Environment(\.injected) private var injected: DIContainer
    
    var body: some View {
        Button(action: startLoginWithKakaoTalk) {
            HStack(alignment: .center) {
                Spacer()
                Image(.kakao)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("카카오로 계속하기")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .opacity(0.85)
                Spacer()
            }
            .frame(height: 54)
            .background(Color.kakao)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Login Flow
    
    private func startLoginWithKakaoTalk() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("❌ Kakao login failed:", error)
                } else if let token = oauthToken {
                    print("✅ Kakao login success")
                    
                    do {
                        try KeyChain.create(key: .kakaoLogin, token: token.idToken ?? "")
                        print("✅ AccessToken saved in KeyChain")
                    } catch {
                        print("❌ Failed to save token to KeyChain:", error)
                    }
                    
                    handleKakaoLogin(token: token)
                }
            }
        }
    }
    
    private func handleKakaoLogin(token: OAuthToken) {
        guard let idToken = token.idToken else { return }
        
        Task {
            do {
                let kakaoInfo = try await fetchKakaoUserInfo()
                updateUser(with: kakaoInfo)

                // 서버 로그인 요청 및 키체인 등록
                // let response = try await performSocialLogin(idToken: idToken, provider: .kakao)
                // try KeyChain.create(key: .accessToken, token: response.accessToken)
                try KeyChain.create(key: .accessToken, token: "test")
                
                // 인증 상태 업데이트
                injected.appState[\.authStatus] = .signedIn(isRegistered: false)
            } catch {
                print("❌ Kakao login failed:", error)
            }
        }
    }
    
    private func fetchKakaoUserInfo() async throws -> KakaoUserInfo {
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = user {
                    let id = String(user.id ?? 0)
                    let email = user.kakaoAccount?.email ?? "이메일 없음"
                    let info = KakaoUserInfo(id: id, email: email)
                    continuation.resume(returning: info)
                } else {
                    continuation.resume(throwing: NSError(domain: "KakaoUserError", code: -1))
                }
            }
        }
    }
    
    // 서버 요청 (TODO 구현 필요)
    /*
    func performSocialLogin(idToken: String, provider: SocialProvider) async throws -> SocialLoginResponse {
        try await injected.networkService.socialLogin(
            provider: provider,
            token: idToken
        )
    }
    */
}

private extension KakaoLogin {
    struct KakaoUserInfo {
        let id: String
        let email: String
    }

    func updateUser(with info: KakaoUserInfo) {
        self.user.id = info.id
        self.user.email = info.email
        self.user.provider = .kakao
    }
}
