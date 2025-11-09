//
//  CollectionSummary.swift
//  saerok
//
//  Created by HanSeung on 5/30/25.
//


import Foundation

extension Local {
    struct CollectionSummary: Identifiable, Hashable {
        let id: Int
        let imageURL: String?
        let thumbnailImageURL: String?
        let birdName: String?
        let createdAt: Date
    }
}

extension Local.CollectionSummary {
    static func from(dto: DTO.CollectionSummary) -> Local.CollectionSummary {
        .init(
            id: dto.collectionId,
            imageURL: dto.imageUrl,
            thumbnailImageURL: dto.thumbnailImageUrl,
            birdName: dto.koreanName,
            createdAt: DateFormatter.iso8601.date(from: dto.createdAt ?? "") ?? .now
        )
    }
}
