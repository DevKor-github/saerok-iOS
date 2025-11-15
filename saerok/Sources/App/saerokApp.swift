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
            .task {
                let migrationKey = "lastMigratedAppVersion2.0.2"
                let context = ModelContext(modelContainer)
                if AppVersionMigrator.needsMigration(forKey: migrationKey) {
                    AppVersionMigrator.wipeRecentSearches(context)
                    AppVersionMigrator.markMigrated(forKey: migrationKey)
                }
            }
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    let _ = AuthController.handleOpenUrl(url: url)
                }
            }
    }
}
