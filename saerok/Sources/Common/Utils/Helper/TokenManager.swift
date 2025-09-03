//
//  TokenManager.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


import Foundation

final class TokenManager {
    @MainActor static let shared = TokenManager()

    private init() {}

    // MARK: - 저장

    func saveTokens(accessToken: String, refreshToken: String?) {
        do {
            try KeyChain.create(key: .accessToken, token: accessToken)

            if let refreshToken {
                try KeyChain.create(key: .refresehToken, token: refreshToken)
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
    
    func getDeviceId() -> String {
        if let existing = try? KeyChain.read(key: .deviceId) {
            return existing
        } else {
            let newID = UUID().uuidString
            do {
                try KeyChain.create(key: .deviceId, token: newID)
            } catch {
                print("🔒 고유번호 생성 실패: \(error)")
            }
            return newID
        }
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
            return .notDetermined
        }
        
        do {
            let endpoint = SREndpoint.refreshToken(refreshToken: refreshToken)
            let response: DTO.AuthResponse = try await SRNetworkServiceImpl().performSRRequest(endpoint)
            
            let newRefreshToken = extractRefreshTokenFromCookies() ?? refreshToken
            saveTokens(accessToken: response.accessToken, refreshToken: newRefreshToken)
            
            if response.signupStatus == .completed {
                syncUserData()
            }
            return .signedIn(isRegistered: response.signupStatus == .completed)
        } catch {
            return .notDetermined
        }
    }
    
    func trySocialLogin(accessToken: String) {
        let newRefreshToken = extractRefreshTokenFromCookies()
        saveTokens(accessToken: accessToken, refreshToken: newRefreshToken)
    }
    
    func syncUserData() {
        Task {
            do {
                let endpoint = SREndpoint.me
                let userResponse: DTO.MeResponse = try await SRNetworkServiceImpl().performSRRequest(endpoint)
                
                await UserManager.shared.syncUser(from: userResponse)
            } catch {
                print("⚠️ 유저 동기화 실패: \(error)")
            }
        }
    }
}
