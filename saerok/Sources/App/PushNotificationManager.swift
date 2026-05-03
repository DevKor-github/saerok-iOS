//
//  PushNotificationManager.swift
//  saerok
//
//  Created by HanSeung on 8/5/25.
//

import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

@MainActor
final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    
    var injected: DIContainer?
    
    private var deviceID: String { TokenManager.shared.getDeviceId() }
    
    private override init() {
        super.init()
    }
    
    func configurePush(application: UIApplication, diContainer: DIContainer) {
        self.injected = diContainer
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        Task { @MainActor in
            try? await handleNotificationAuthorization(application)
        }
    }
    
    func isDeniedNotificationPermission() async -> Bool {
        let status = await checkNotificationAuthorization()
        return status == .denied
    }

    func reRegisterDevice() async {
        guard let fcmToken = Messaging.messaging().fcmToken,
              let interactor = injected?.interactors.user
        else { return }

        try? await interactor.registerDeviceToken(deviceID: deviceID, fcmToken: fcmToken)
        try? await interactor.toggleAllNotificationSetting()
    }
    
    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
}

// MARK: - Handling Notification Register
private extension PushNotificationManager {
    func handleNotificationAuthorization(_ application: UIApplication) async throws {
        let status = await checkNotificationAuthorization()
        switch status {
        case .notDetermined:
            let granted = try await requestAuthorization()
            if granted { application.registerForRemoteNotifications() }

        case .authorized, .provisional, .ephemeral:
            application.registerForRemoteNotifications()

        case .denied:
            break

        @unknown default:
            break
        }
    }
    
    func checkNotificationAuthorization() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
}

// MARK: - APNs Routing
extension PushNotificationManager: @MainActor UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    @MainActor
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let type = parseNotificationType(from: userInfo),
           let relatedId = parseRelatedId(from: userInfo) {
            handleDeepLink(for: type, relatedId)
        }
        
        if let notificationId = parseNotificationId(from: userInfo),
           let interactor = injected?.interactors.user {
            Task {
                do {
                    try await interactor.readNotification(notificationId)
                } catch { }
            }
        }
        
        completionHandler()
    }
    
    private func handleDeepLink(for type: Local.NotificationType, _ id: Int) {
        guard let appState = injected?.appState else { return }
        
        appState.bulkUpdate {
            switch type {
            case .system:
                $0.routing.contentView.tabSelection = .profile
                $0.routing.myPageView.boardDetailId = id
            default:
                $0.routing.contentView.tabSelection = .collection
                $0.routing.collectionView.collectionID = id
            }
        }
    }
    
    private func parseNotificationType(from userInfo: [AnyHashable: Any]) -> Local.NotificationType? {
        guard let type = userInfo["type"] as? String else { return nil }
        
        switch type {
        case Local.NotificationType.system.rawValue:
            return .system
        default:
            return .comment
        }
    }
    
    private func parseRelatedId(from userInfo: [AnyHashable: Any]) -> Int? {
        return (userInfo["relatedId"] as? Int) ??
        (userInfo["relatedId"] as? NSNumber)?.intValue ??
        (userInfo["relatedId"] as? String).flatMap(Int.init)
    }
    
    private func parseNotificationId(from userInfo: [AnyHashable: Any]) -> Int? {
        return (userInfo["notificationId"] as? Int) ??
        (userInfo["notificationId"] as? NSNumber)?.intValue ??
        (userInfo["notificationId"] as? String).flatMap(Int.init)
    }
}

// MARK: - FCM Registering
extension PushNotificationManager: @MainActor MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken,
              let interactor = injected?.interactors.user
        else { return }
        
        Task { @MainActor in
            do {
                try await interactor.registerDeviceToken(deviceID: deviceID, fcmToken: fcmToken)
            } catch { }
        }
    }
}
