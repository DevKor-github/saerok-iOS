//
//  AppleLoginView.swift
//  saerok
//
//  Created by HanSeung on 5/21/25.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginView: View {
    @Environment(\.injected) private var injected: DIContainer

    @Binding var user: User

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
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("❌ Failed to get identityToken")
                return
            }
            
            guard let authorizationCode = credential.authorizationCode,
                  let codeString = String(data: authorizationCode, encoding: .utf8) else { return }
            
            Task {
                await handleAppleLogin(
                    id: credential.user,
                    email: credential.email,
                    authorizationCode: codeString
                )
            }

        case .failure(let error):
            print("❌ Apple Authorization failed: \(error.localizedDescription)")
        }
    }
    
    func handleAppleLogin(id: String, email: String?, authorizationCode: String) async {
        do {
            let response: DTO.AuthResponse = try await injected
                .networkService
                .performSRRequest(.appleLogin(authorizationCode: authorizationCode))
            TokenManager.shared.trySocialLogin(accessToken: response.accessToken)
            await MainActor.run {
                user.id = id
                user.email = email ?? "Unknown"
                user.provider = .apple
                
                injected.appState[\.authStatus] = .signedIn(isRegistered: response.signupStatus == .completed)
            }
        } catch {
            print("❌ Apple login failed:", error)
        }
    }
}
