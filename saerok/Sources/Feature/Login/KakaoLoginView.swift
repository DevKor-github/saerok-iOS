//
//  KakaoLoginView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth

struct KakaoLoginView: View {
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
}
// MARK: - Login Flow

private extension KakaoLoginView {
    func startLoginWithKakaoTalk() {
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 앱 로그인
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                handleLoginResult(oauthToken, error: error)
            }
        } else {
            // 앱이 없거나 시뮬레이터일 경우 웹 로그인
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                handleLoginResult(oauthToken, error: error)
            }
        }
    }

    private func handleLoginResult(_ oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("❌ Kakao login failed:", error)
            return
        }
        
        guard let token = oauthToken else {
            print("❌ Failed to get idToken from Kakao")
            return
        }
        
        Task {
            await handleKakaoLogin(token: token)
        }
    }
    
    func handleKakaoLogin(token: OAuthToken) async {
        do {
            let kakaoInfo = try await fetchKakaoUserInfo()
            let response: DTO.AuthResponse = try await injected
                .networkService
                .performSRRequest(.kakaoLogin(accessCode: token.accessToken))
            
            TokenManager.shared.trySocialLogin(accessToken: response.accessToken)

            await MainActor.run {
                user.id = kakaoInfo.id
                user.email = kakaoInfo.email
                user.provider = .kakao

                injected.appState[\.authStatus] = .signedIn(isRegistered: response.signupStatus == .completed)
            }
        } catch {
            print("❌ Kakao login failed2:", error)
        }
    }
    
    func fetchKakaoUserInfo() async throws -> KakaoUserInfo {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = user {
                    let id = String(user.id ?? 0)
                    let email = user.kakaoAccount?.email ?? "이메일 없음"
                    continuation.resume(returning: KakaoUserInfo(id: id, email: email))
                } else {
                    continuation.resume(throwing: NSError(domain: "KakaoUserError", code: -1))
                }
            }
        }
    }
    
    struct KakaoUserInfo {
        let id: String
        let email: String
    }
}
