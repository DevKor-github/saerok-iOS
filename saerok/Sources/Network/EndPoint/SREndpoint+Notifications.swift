//
//  SREndpoint+Notifications.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Notifications API

extension SREndpoint {
    static func registerDeviceToken(body: DTO.RegisterDeviceTokenRequest) -> SREndpoint {
        SREndpoint(
            path: "notifications/tokens",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.RegisterDeviceTokenResponse.self
        )
    }

    static func getNotificationSettings(deviceId: String) -> SREndpoint {
        SREndpoint(
            path: "notifications/settings",
            auth: .required,
            query: ["deviceId": deviceId, "platform": "IOS"],
            response: DTO.GetNotificationSettingsResponse.self
        )
    }

    static func toggleNotificationSetting(body: DTO.ToggleNotificationRequest) -> SREndpoint {
        SREndpoint(
            path: "notifications/settings/toggle",
            method: .patch,
            auth: .required,
            body: jsonBody(body),
            json: true,
            response: DTO.ToggleNotificationResponse.self
        )
    }

    static var notifications: SREndpoint {
        SREndpoint(path: "notifications", auth: .required, response: DTO.NotificationResponse.self)
    }

    static var readAllNotifications: SREndpoint {
        SREndpoint(path: "notifications/read-all", method: .patch, auth: .required)
    }

    static func readNotification(notificationId: Int) -> SREndpoint {
        SREndpoint(path: "notifications/\(notificationId)/read", method: .patch, auth: .required)
    }

    static var deleteAllNotifications: SREndpoint {
        SREndpoint(path: "notifications/all", method: .delete, auth: .required)
    }

    static func deleteNotification(_ notificationId: Int) -> SREndpoint {
        SREndpoint(path: "notifications/\(notificationId)", method: .delete, auth: .required)
    }

    static var notificationsUnreadCount: SREndpoint {
        SREndpoint(path: "notifications/unread-count", auth: .required, response: DTO.GetUnreadCount.self)
    }
}
