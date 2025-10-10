//
//  AppVersionMigrator.swift
//  saerok
//
//  Created by HanSeung on 10/8/25.
//


import Foundation
import SwiftData

enum AppVersionMigrator {
    static func currentVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
    
    static func needsMigration(forKey key: String) -> Bool {
        let lastVersion = UserDefaults.standard.string(forKey: key)
        return lastVersion != currentVersion()
    }
    
    static func markMigrated(forKey key: String) {
        UserDefaults.standard.set(currentVersion(), forKey: key)
    }
    
    static func wipeRecentSearches(_ modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Local.RecentSearchEntity>()
        if let items = try? modelContext.fetch(descriptor) {
            for item in items {
                modelContext.delete(item)
            }
            try? modelContext.save()
        }
    }
}
