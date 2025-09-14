//
//  CollectionLikeUsersResponse.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//


extension DTO {
    struct CollectionLikeUsersResponse: Codable {
        let items: [UserLikeInfo]
    }

    struct UserLikeInfo: Codable {
        let userId: Int
        let nickname: String
        let profileImageUrl: String
    }
}