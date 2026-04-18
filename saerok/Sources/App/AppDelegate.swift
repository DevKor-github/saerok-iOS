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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        startSDKs(application: application)
        return true
    }
    
    var rootView: some View {
        environment.rootView
    }

    private func startSDKs(application: UIApplication) {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
        PushNotificationManager.shared.configurePush(
            application: application,
            diContainer: environment.diContainer
        )
    }
}
