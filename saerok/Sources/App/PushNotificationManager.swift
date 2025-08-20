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
        
        requestAuthorization()
        application.registerForRemoteNotifications()
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }
    
    private func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
        }
    }
    
    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let relatedId = parseRelatedId(from: userInfo) {
            handleDeepLink(relatedId)
        }
        
        if let notificationId = parseNotificationId(from: userInfo),
           let networkService = injected?.networkService {
            Task {
                do {
                    let _: EmptyResponse = try await networkService.performSRRequest(
                        .readNotification(notificationId: notificationId)
                    )
                } catch {
                    print("알림 읽음 처리 실패: \(error)")
                }
            }
        }
        
        completionHandler()
    }
    
    private func handleDeepLink(_ num: Int) {
        Task { @MainActor in
            self.injected?.appState[\.routing.collectionView.collectionID] = num
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

extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken,
              let networkService = injected?.networkService
        else { return }
        
        Task { @MainActor in
            do {
                let _: DTO.RegisterDeviceTokenResponse = try await networkService.performSRRequest(
                    .registerDeviceToken(body: .init(deviceId: deviceID, token: fcmToken))
                )
                try await self.injected?.interactors.user.toggleNotificationSetting(.comment)
                try await self.injected?.interactors.user.toggleNotificationSetting(.birdIdSuggestion)
                try await self.injected?.interactors.user.toggleNotificationSetting(.like)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
