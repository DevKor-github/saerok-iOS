//
//  saerokApp.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import Combine
import SwiftUI
import SwiftData

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@main
struct saerokApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoAppID)
    }
    
    var body: some Scene {
        WindowGroup {
            appDelegate.rootView
        }
    }
}

extension AppEnvironment {
    var rootView: some View {
        RootSelectorView()
            .modelContainer(modelContainer)
            .inject(diContainer)
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    let _ = AuthController.handleOpenUrl(url: url)
                }
            }
    }
}
