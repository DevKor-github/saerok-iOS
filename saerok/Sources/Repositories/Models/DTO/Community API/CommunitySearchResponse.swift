//
//  CommunitySearchResponse.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


import Foundation

extension DTO {
    struct CommunitySearchResponse: Decodable {
        let collectionsCount: Int
        let collections: [CommunityItem]
        let usersCount: Int
        let users: [CommunitySearchUserItem]
    }
    
    struct CommunitySearchUsersResponse: Decodable {
        let items: [CommunitySearchUserItem]
    }

    struct CommunitySearchCollectionsResponse: Decodable {
        let items: [CommunityItem]
    }
}

extension DTO {
    struct CommunitySearchUserItem: Decodable {
        let userId: Int
        let nickname: String
        let profileImageUrl: String
    }
}
