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
        let imageUrl: String
        let koreanName: String
        let note: String
    }
}
