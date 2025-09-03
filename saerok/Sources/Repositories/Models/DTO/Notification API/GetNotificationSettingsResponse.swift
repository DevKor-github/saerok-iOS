//
//  GetNotificationSettingsResponse.swift
//  saerok
//
//  Created by HanSeung on 8/12/25.
//


extension DTO {
    struct GetNotificationSettingsResponse: Decodable {
        let deviceId: String
        let items: [Item]

        struct Item: Decodable {
            let type: NotificationType
            let enabled: Bool
        }
    }
}
