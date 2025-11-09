//
//  UserProfileSummary.swift
//  saerok
//
//  Created by HanSeung on 10/9/25.
//


import Foundation

extension Local {
    struct UserProfileSummary {
        let joinedDate: Date
        let userSummary: Local.UserSummary
        let collections: [Local.CollectionSummary]
        let collectionCount: Int
    }
}

extension Local.UserProfileSummary {
    static func from(_ dto: DTO.ProfileResponse) -> Self {
        .init(
            joinedDate: Date.fromSimpleDateString(dto.joinedDate) ?? .now,
            userSummary: .init(id: 0, nickname: dto.nickname, profileImageUrl: dto.profileImageUrl),
            collections: dto.collections
                .map {
                    .init(
                        id: $0.collectionId,
                        imageURL: $0.imageUrl,
                        thumbnailImageURL: $0.thumbnailImageUrl,
                        birdName: $0.birdKoreanName,
                        createdAt: Date.fromSimpleDateString($0.uploadedDate) ?? .now
                    )
                },
            collectionCount: dto.collectionCount
        )
    }
}
