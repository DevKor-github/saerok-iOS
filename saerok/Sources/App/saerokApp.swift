//
//  saerokApp.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI
import SwiftData

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
        ContentView()
            .modelContainer(modelContainer)
            .inject(diContainer)
    }
}
