//
//  CommunityCollectionSummary.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


import Foundation

extension Local {
    struct CommunityItemSummary: Identifiable, Equatable {
        let id: Int
        let imageURL: String?
        let thumbnailImageUrl: String?
        let discoveredDate: Date?
        let createdAt: Date
        let latitude: Double
        let longitude: Double
        let locationAlias: String
        let address: String?
        let note: String
        let likeCount: Int
        let commentCount: Int
        let isLiked: Bool
        let isPopular: Bool
        let birdId: Int?
        let birdName: String?
        let user: UserSummary
        let suggestionUserCount: Int?
    }
}

extension Local.CommunityItemSummary {
    static func from(dto: DTO.CommunityItem) -> Self {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .init(secondsFromGMT: 0)
        let date: Date = formatter.date(from: dto.discoveredDate) ?? .now
        
        return .init(
            id: dto.collectionId,
            imageURL: dto.imageUrl,
            thumbnailImageUrl: dto.thumbnailImageUrl,
            discoveredDate: date,
            createdAt: DateFormatter.iso8601.date(from: dto.createdAt) ?? .now,
            latitude: dto.latitude,
            longitude: dto.longitude,
            locationAlias: dto.locationAlias ?? "",
            address: dto.address,
            note: dto.note ?? "",
            likeCount: dto.likeCount,
            commentCount: dto.commentCount,
            isLiked: dto.isLiked,
            isPopular: dto.isPopular,
            birdId: dto.bird?.birdId,
            birdName: dto.bird?.koreanName,
            user: .from(dto: dto.user),
            suggestionUserCount: dto.suggestionUserCount
        )
    }
}
