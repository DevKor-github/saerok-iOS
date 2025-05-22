//
//  AppleLoginView.swift
//  saerok
//
//  Created by HanSeung on 5/21/25.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginView: View {
    @Binding var user: User
    @Environment(\.injected) private var injected: DIContainer

    var body: some View {
        signInButton
    }
    
    private var signInButton: some View {
        ZStack {
            SignInWithAppleButton(
                .continue,
                onRequest: { $0.requestedScopes = [.email] },
                onCompletion: handleAuthorization
            )
            .frame(height: 54)
            .signInWithAppleButtonStyle(.black)
            Rectangle().fill(.white)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            HStack {
                Image(systemName: "applelogo")
                    .font(.title2)
                Text("Apple로 계속하기")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(12)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Auth Handling

private extension AppleLoginView {
    func handleAuthorization(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                print("❌ Failed to get identityToken")
                return
            }

            Task {
                await handleAppleLogin(
                    id: credential.user,
                    email: credential.email,
                    identityToken: identityToken
                )
            }

        case .failure(let error):
            print("❌ Apple Authorization failed: \(error.localizedDescription)")
        }
    }

    func handleAppleLogin(id: String, email: String?, identityToken: String) async {
        do {
            // TODO: 서버 로그인 요청 및 키체인 등록
            // let response = try await injected.networkService.socialLogin(provider: .apple, token: identityToken)
            try KeyChain.create(key: .accessToken, token: "test-access-token") // 예시용

            await MainActor.run {
                user.id = id
                user.email = email ?? "Unknown"
                user.provider = .apple

                injected.appState[\.authStatus] = .signedIn(isRegistered: false)
            }
        } catch {
            print("❌ Apple login failed:", error)
        }
    }
}
