//
//  ToggleNotificationSettingRequest.swift
//  saerok
//
//  Created by HanSeung on 8/12/25.
//


extension DTO {
    struct ToggleNotificationRequest: Codable {
        let deviceId: String
        let type: String
    }
    
    struct ToggleNotificationResponse: Decodable {
        let deviceId: String
        let type: String
        let enabled: Bool
    }
}
