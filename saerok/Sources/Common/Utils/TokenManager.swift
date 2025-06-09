//
//  TokenManager.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


import Foundation

final class TokenManager {
    static let shared = TokenManager()

    private init() {}

    // MARK: - 저장

    func saveTokens(accessToken: String, refreshToken: String?) {
        do {
            try KeyChain.create(key: .accessToken, token: accessToken)
            print("액세스토큰저장")
            if let refreshToken {
                try KeyChain.create(key: .refresehToken, token: refreshToken)
                print("리프레시토큰저장")
            }
        } catch {
            print("🔒 Token 저장 실패: \(error)")
        }
    }

    // MARK: - 불러오기

    func getAccessToken() -> String? {
        return try? KeyChain.read(key: .accessToken)
    }

    func getRefreshToken() -> String? {
        return try? KeyChain.read(key: .refresehToken)
    }

    // MARK: - 삭제

    func clearTokens() {
        do {
            try KeyChain.delete(key: .accessToken)
            try KeyChain.delete(key: .refresehToken)
        } catch {
            print("🔒 Token 삭제 실패: \(error)")
        }
    }

    // MARK: - 쿠키에서 Refresh Token 추출

    func extractRefreshTokenFromCookies() -> String? {
        HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "refreshToken" })?.value
    }

    // MARK: - 자동 로그인
    
    func tryAutoLogin() async -> AppState.AuthStatus {
        guard let refreshToken = getRefreshToken() else {
            print("🔒 refreshToken 없음 - 자동 로그인 실패")
            return .notDetermined
        }
        
        do {
            let endpoint = SREndpoint.refreshToken(refreshToken: refreshToken)
            let response: DTO.AuthResponse = try await SRNetworkServiceImpl().performSRRequest(endpoint)
            
            let newRefreshToken = extractRefreshTokenFromCookies() ?? refreshToken
            saveTokens(accessToken: response.accessToken, refreshToken: newRefreshToken)
            
            print("🔓 자동 로그인 성공")
            return .signedIn(isRegistered: response.signupStatus == .completed)
        } catch {
            print("🔒 자동 로그인 실패: \(error)")
            return .notDetermined
        }
    }
    
    func trySocialLogin(accessToken: String) {
        let newRefreshToken = extractRefreshTokenFromCookies()
        saveTokens(accessToken: accessToken, refreshToken: newRefreshToken)
    }
}
