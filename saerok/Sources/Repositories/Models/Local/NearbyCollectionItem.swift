//
//  NearbyCollectionItem.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//


extension Local {
    struct NearbyCollectionSummary: Decodable, Equatable {
        let collectionId: Int
        let imageUrl: String?
        let koreanName: String?
        let latitude: Double
        let longitude: Double
        let note: String
    }
}


extension Local.NearbyCollectionSummary {
    static func from(dto: DTO.NearbyCollectionItem) -> Local.NearbyCollectionSummary {
        return .init(
            collectionId: dto.collectionId,
            imageUrl: dto.imageUrl,
            koreanName: dto.koreanName,
            latitude: dto.latitude,
            longitude: dto.longitude,
            note: dto.note
        )
    }
}
