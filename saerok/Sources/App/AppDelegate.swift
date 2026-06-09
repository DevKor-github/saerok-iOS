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

    /// APNs 디바이스 토큰을 FCM에 명시적으로 연결한다.
    /// Firebase method swizzling 비활성화(`FirebaseAppDelegateProxyEnabled = NO`) 환경에서도
    /// APNs↔FCM 매핑이 끊기지 않도록 직접 주입한다.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationManager.shared.setAPNSToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        #if DEBUG
        print("[Push] APNs 등록 실패: \(error.localizedDescription)")
        #endif
    }

    private func startSDKs(application: UIApplication) {
        configureFirebase()
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
        PushNotificationManager.shared.configurePush(
            application: application,
            diContainer: environment.diContainer
        )
    }

    /// 환경별 Firebase 설정 파일을 선택해 초기화한다.
    /// Debug(테스트 번들 `com.apu.saerok.dev`)는 `GoogleService-Info-Dev.plist`,
    /// Release(운영 번들 `com.apu.saerok`)는 기본 `GoogleService-Info.plist`를 사용한다.
    private func configureFirebase() {
        #if DEBUG
        let resourceName = "GoogleService-Info-Dev"
        #else
        let resourceName = "GoogleService-Info"
        #endif

        guard
            let path = Bundle.main.path(forResource: resourceName, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path)
        else {
            assertionFailure("[Firebase] \(resourceName).plist를 찾을 수 없습니다. 프로젝트에 추가했는지 확인하세요.")
            FirebaseApp.configure()
            return
        }
        FirebaseApp.configure(options: options)
    }
}
