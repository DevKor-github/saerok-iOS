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
            .inject(diContainer, coordinator: coordinator)
            .task {
                let migrationKey = "lastMigratedAppVersion2.5.3"
                let context = ModelContext(modelContainer)
                if AppVersionMigrator.needsMigration(forKey: migrationKey) {
                    AppVersionMigrator.wipeRecentSearches(context)
                    AppVersionMigrator.markMigrated(forKey: migrationKey)
                }
                
                // 사용자 차단
                await diContainer.interactors.user.syncBlockable()
            }
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    let _ = AuthController.handleOpenUrl(url: url)
                }
            }
    }
}
