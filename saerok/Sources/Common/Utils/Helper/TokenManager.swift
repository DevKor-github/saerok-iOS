//
//  TokenManager.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


import Foundation
import Security

actor TokenManager {
    static let shared = TokenManager()
    private init() {}

    // MARK: - 저장
    func saveTokens(accessToken: String, refreshToken: String?) {
        do {
            try KeyChain.create(key: .accessToken, token: accessToken)

            if let refreshToken {
                try KeyChain.create(key: .refreshToken, token: refreshToken)
            }
        } catch { }
    }

    // MARK: - 불러오기
    nonisolated func getAccessToken() -> String? {
        return try? KeyChain.read(key: .accessToken)
    }

    nonisolated func getRefreshToken() -> String? {
        return try? KeyChain.read(key: .refreshToken)
    }
    
    nonisolated func getDeviceId() -> String {
        if let existing = try? KeyChain.read(key: .deviceId) {
            return existing
        } else {
            let newID = UUID().uuidString
            do {
                try KeyChain.create(key: .deviceId, token: newID)
            } catch { }
            return newID
        }
    }

    // MARK: - 삭제
    func clearTokens() {
        do {
            try KeyChain.delete(key: .accessToken)
            try KeyChain.delete(key: .refreshToken)
        } catch { }
    }

    // MARK: - 쿠키에서 Refresh Token 추출
    func extractRefreshTokenFromCookies() -> String? {
        HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "refreshToken" })?.value
    }

    // MARK: - 자동 로그인
    func tryAutoLogin() async throws  -> AppState.AuthStatus {
        guard let refreshToken = getRefreshToken() else {
            return .notDetermined
        }
        
        let endpoint = SREndpoint.refreshToken(refreshToken: refreshToken)
        let response: DTO.AuthResponse = try await SRNetworkServiceImpl().performSRRequest(endpoint)
        
        let newRefreshToken = extractRefreshTokenFromCookies() ?? refreshToken
        saveTokens(accessToken: response.accessToken, refreshToken: newRefreshToken)
        
        return .signedIn(isRegistered: response.signupStatus == .completed)
    }

    func trySocialLogin(accessToken: String) {
        let newRefreshToken = extractRefreshTokenFromCookies()
        saveTokens(accessToken: accessToken, refreshToken: newRefreshToken)
    }
}

fileprivate final class KeyChain {
    enum KeyInfo: String {
        case accessToken
        case refreshToken
        case deviceId
    }
    
    static func create(key: KeyInfo, token: String) throws {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        SecItemDelete(query)

        let status = SecItemAdd(query, nil)
        guard status == noErr else { throw KeyChainError.creationFailed }
    }
    
    static func read(key: KeyInfo) throws -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData: Data = dataTypeRef as? Data {
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                return value
            } else { return nil }
        } else {
            throw KeyChainError.notFound
        }
    }
    
    static func delete(key: KeyInfo) throws {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        let status = SecItemDelete(query)
        guard status == noErr else { throw KeyChainError.deletionFailed }
    }
}

enum KeyChainError: Error {
    case notFound
    case creationFailed
    case deletionFailed
}
