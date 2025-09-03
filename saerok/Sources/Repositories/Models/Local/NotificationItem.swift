//
//  NotificationItem.swift
//  saerok
//
//  Created by HanSeung on 8/17/25.
//


import Foundation

extension Local {
    struct NotificationItem {
        let notificationId: Int
        let actorImageUrl: String
        let actorNickname: String
        let collectionId: Int
        let collectionImageUrl: String?
        let createdAt: Date
        let type: Local.NotificationType
        let content: String?
        var isRead: Bool
    }
}

extension Local.NotificationItem {
    init(from dto: DTO.NotificationItem) throws {
        self.notificationId = dto.id
        self.actorNickname = dto.actorNickname
        self.actorImageUrl = dto.actorProfileImageUrl

        switch dto.type {
        case .likedOnCollection:
            self.type = .like
            self.collectionId = dto.payload.collectionId
            self.collectionImageUrl = dto.payload.collectionImageUrl
            self.content = nil

        case .commentedOnCollection:
            self.type = .comment
            self.collectionId = dto.payload.collectionId
            self.collectionImageUrl = dto.payload.collectionImageUrl
            self.content = dto.payload.comment

        case .suggestedBirdIdOnCollection:
            self.type = .birdIdSuggestion
            self.collectionId = dto.payload.collectionId
            self.collectionImageUrl = dto.payload.collectionImageUrl
            self.content = dto.payload.suggestedName
        }

        self.createdAt = DateFormatter.iso8601.date(from: dto.createdAt) ?? .now
        self.isRead = dto.isRead
    }
}

extension Array where Element == Local.NotificationItem {
    init(from dto: DTO.NotificationResponse) {
        self = dto.items.compactMap { item in
            try? Local.NotificationItem(from: item)
        }
    }
}
