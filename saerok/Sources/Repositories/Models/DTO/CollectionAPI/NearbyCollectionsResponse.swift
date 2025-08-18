//
//  NearbyCollectionsResponse.swift
//  saerok
//
//  Created by HanSeung on 6/6/25.
//


extension DTO {
    struct NearbyCollectionsResponse: Decodable {
        let items: [NearbyCollectionItem]
    }

    struct NearbyCollectionItem: Decodable {
        let collectionId: Int
        let imageUrl: String?
        let koreanName: String?
        let note: String
        let latitude: Double
        let longitude: Double
        let locationAlias: String
        let address: String
        let likeCount: Int
        let commentCount: Int
        let isLiked: Bool
        let user: User
    }
    
    struct User: Codable {
        let userId: Int
        let nickname: String
        let profileImageUrl: String
    }
}
