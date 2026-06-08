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
        guard let interactor = injected?.interactors.user else { return }

        // 로그아웃 시 토큰을 폐기했다면 fcmToken이 nil일 수 있으므로,
        // 비어 있으면 새 토큰을 비동기로 발급받아 등록한다.
        var fcmToken = Messaging.messaging().fcmToken
        if fcmToken == nil {
            fcmToken = try? await Messaging.messaging().token()
        }
        guard let fcmToken else { return }

        try? await interactor.registerDeviceToken(deviceID: deviceID, fcmToken: fcmToken)
    }

    /// 로그아웃·회원탈퇴 시 현재 기기의 FCM 토큰을 폐기(rotate)한다.
    ///
    /// 백엔드에는 디바이스 토큰을 삭제하는 API가 없으므로, 클라이언트가 FCM 토큰을 직접
    /// 만료시켜 이전 계정의 `UserDevice` 행에 남은 토큰을 무효화한다.
    /// - 무효화된 토큰으로의 발송은 즉시 차단되어, 같은 기기에 다른 계정으로 로그인해도
    ///   이전 계정의 푸시가 새지 않는다(계정 누수 차단).
    /// - 무효 토큰은 다음 발송 시 FCM이 `UNREGISTERED`를 반환하고, 백엔드의 무효 토큰 정리
    ///   (`cleanupInvalidTokens`)가 해당 행을 제거한다.
    /// - 토큰 폐기로 새 FCM 토큰이 발급되어, 다음 로그인 계정은 이전 계정과 공유되지 않는
    ///   토큰으로 등록된다.
    func unregisterDevice() async {
        try? await Messaging.messaging().deleteToken()
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
        guard let appStore = injected?.appStore else { return }

        switch type {
        case .system:
            appStore.send(.selectTab(.profile))
            appStore.send(.openBoardDetail(id))
        case .freeBoardComment, .freeBoardReply:
            appStore.send(.selectTab(.community))
            appStore.send(.openFreeBoardPost(id))
        case .adminMessage:
            appStore.send(.selectTab(.collection))
            appStore.send(.openNotificationView)
        default:
            appStore.send(.selectTab(.collection))
            appStore.send(.openCollectionDetail(id))
        }
    }
    
    private func parseNotificationType(from userInfo: [AnyHashable: Any]) -> Local.NotificationType? {
        guard let type = userInfo["type"] as? String else { return nil }
        return Local.NotificationType(rawValue: type)
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
