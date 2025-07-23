//
//  AppDelegate.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftUI
import UIKit

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
}
