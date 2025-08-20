//
//  RegisterDeviceTokenResponse.swift
//  saerok
//
//  Created by HanSeung on 8/12/25.
//


extension DTO {
    struct RegisterDeviceTokenRequest: Codable {
        let deviceId: String
        let token: String
    }
    
    struct RegisterDeviceTokenResponse: Decodable {
        let deviceId: String
        let success: Bool
    }
}
