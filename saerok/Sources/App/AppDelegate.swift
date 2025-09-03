//
//  AppDelegate.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


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
    func applicationWillEnterForeground(_ application: UIApplication) {
        Task { @MainActor in
            environment.diContainer.appState[\.authStatus] = await TokenManager.shared.tryAutoLogin()
        }
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        PushNotificationManager.shared.configurePush(application: application, diContainer: environment.diContainer)
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationManager.shared.setAPNSToken(deviceToken)
    }
}

