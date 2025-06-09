//
//  CollectionSummaryResponse.swift
//  saerok
//
//  Created by HanSeung on 5/29/25.
//

extension DTO {
    struct MyCollectionsResponse: Codable {
        let items: [CollectionSummary]
    }

    struct CollectionSummary: Codable, Identifiable {
        let collectionId: Int
        let imageUrl: String?
        let koreanName: String?
        
        var id: Int { collectionId }
    }
}
