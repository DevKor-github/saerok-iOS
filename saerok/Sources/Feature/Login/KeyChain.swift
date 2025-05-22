//
//  KeyChain.swift
//  SocialLogin
//
//  Created by HanSeung on 3/21/25.
//


import Foundation
import Security

final class KeyChain {
    enum KeyInfo: String {
        case accessToken
        case appleLogin
        case kakaoLogin
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
