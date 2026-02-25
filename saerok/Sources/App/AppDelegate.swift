//
//  AppDelegate.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import AppTrackingTransparency
import SwiftUI
import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseCore

@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private lazy var environment = AppEnvironment.bootstrap()
    
    var rootView: some View {
        environment.rootView
    }
}

// MARK: - Lifecycle
extension AppDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
        PushNotificationManager.shared.configurePush(
            application: application,
            diContainer: environment.diContainer
        )
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.requestTrackingAuthorization()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let unreadCount = userInfo["unreadCount"] as? Int {
            UNUserNotificationCenter.current().setBadgeCount(unreadCount)
        }
        
        completionHandler(.newData)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationManager.shared.setAPNSToken(deviceToken)
    }
    
    private func requestTrackingAuthorization() {
        Task {
            _ = await ATTrackingManager.requestTrackingAuthorization()
        }
    }
}
