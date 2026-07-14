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
    
    /// 도감·지도 검색 기록 전체 삭제.
    /// 검색 기록 엔티티에 필드가 추가될 때(예: `uuid` 도메인 식별자) 라이트웨이트 마이그레이션의
    /// 기본값 채움을 신뢰하는 대신, 소모성 데이터인 검색 기록을 wipe하고 새로 쌓는다.
    static func wipeRecentSearches(_ modelContext: ModelContext) {
        if let items = try? modelContext.fetch(FetchDescriptor<Local.RecentSearchEntity>()) {
            for item in items {
                modelContext.delete(item)
            }
        }
        if let items = try? modelContext.fetch(FetchDescriptor<Local.RecentMapSearchEntity>()) {
            for item in items {
                modelContext.delete(item)
            }
        }
        try? modelContext.save()
    }
}
