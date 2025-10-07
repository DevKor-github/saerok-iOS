//
//  CommunityMainResponse.swift
//  saerok
//
//  Created by Assistant on 9/23/25.
//

import Foundation

extension DTO {
    struct CommunityMainResponse: Decodable {
        let recentCollections: [CommunityItem]
        let popularCollections: [CommunityItem]
        let pendingCollections: [CommunityItem]
    }
}

extension DTO {
    // MARK: - 공통 컬렉션 아이템
    struct CommunityItem: Decodable {
        let collectionId: Int
        let imageUrl: String?
        let discoveredDate: String
        let latitude: Double
        let longitude: Double
        let locationAlias: String?
        let address: String?
        let note: String?
        let likeCount: Int
        let commentCount: Int
        let isLiked: Bool
        let isPopular: Bool
        let bird: BirdInfo?
        let user: UserInfo?
        let suggestionUserCount: Int?
        
        struct BirdInfo: Decodable {
            let birdId: Int
            let koreanName: String
        }

        struct UserInfo: Decodable {
            let userId: Int
            let nickname: String
            let profileImageUrl: String
        }
    }
}
