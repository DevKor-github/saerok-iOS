//
//  BlockedUserStorage.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

struct BlockedUserStorage {
    private static let blockedUserIdsKey = "BlockedUserIds"
    private static let blockableKey = "blockable"

    static func readBlockedUserIds() -> [Int] {
        UserDefaults.standard.array(forKey: blockedUserIdsKey) as? [Int] ?? []
    }

    static func addBlockedUserId(_ id: Int) {
        var ids = readBlockedUserIds()
        guard ids.contains(id) == false else { return }
        ids.append(id)
        UserDefaults.standard.set(ids, forKey: blockedUserIdsKey)
    }

    static func isBlockable() -> Bool {
//        UserDefaults.standard.bool(forKey: blockableKey)
        false
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: blockedUserIdsKey)
        UserDefaults.standard.removeObject(forKey: blockableKey)
    }
}
