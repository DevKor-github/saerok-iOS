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
        PushNotificationManager.shared.configurePush(application: application, diContainer: environment.diContainer)
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoTestAppID)
//        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
        
        Task { @MainActor in
            environment.diContainer.appState[\.authStatus] = await TokenManager.shared.tryAutoLogin()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.requestTrackingAuthorization()
        }
        
        return true
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
            print("ATT 요청이 완료되었습니다.")
        }
    }
}

