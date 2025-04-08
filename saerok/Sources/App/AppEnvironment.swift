//
//  AppEnvironment.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import SwiftData

@MainActor
struct AppEnvironment {
    let isRunningTests: Bool
    let modelContainer: ModelContainer
    
    private static func configuredModelContainer() -> ModelContainer {
        do {
            return try ModelContainer.appModelContainer()
        } catch {
            return ModelContainer.previewable
        }
    }
}
