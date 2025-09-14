//
//  UserSummary.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//


extension Local {
    struct UserSummary: Identifiable, Hashable {
        let id: Int
        let nickname: String
        let profileImageUrl: String
    }
}