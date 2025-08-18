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
        let birdName: String?
    }
}

extension Local.CollectionSummary {
    static func from(dto: DTO.CollectionSummary) -> Local.CollectionSummary {
        .init(
            id: dto.collectionId,
            imageURL: dto.imageUrl,
            birdName: dto.koreanName
        )
    }
}

extension Local.CollectionSummary {
    static let mockData: [Local.CollectionSummary] = [
        .init(
            id: 1,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706182907626_U2GYB4NMS.jpg/ia82_327_i4.jpg?type=m1500",
            birdName: "가짜청딱따구리"
        ),
        .init(
            id: 2,
            imageURL: "https://dbscthumb-phinf.pstatic.net/5041_000_1/20171207142615274_7IO0RPQAT.jpg/ib68_188_i3.jpg?type=m1500",
            birdName: "가짜참새"
        ),
        .init(
            id: 3,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706175201747_5965PTVUI.jpg/ia82_278_i4.jpg?type=m1500",
            birdName: "가짜참매"
        ),
        .init(
            id: 4,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706152059339_0WNI1C2F5.jpg/ia82_93_i4.jpg?type=m1500",
            birdName: "가짜갈매기"
        ),
        .init(
            id: 5,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706175201747_5965PTVUI.jpg/ia82_278_i4.jpg?type=m1500",
            birdName: "가짜쇠백로"
        )
    ]
}
