//
//  NotificationItem.swift
//  saerok
//
//  Created by HanSeung on 8/17/25.
//

import Foundation

extension Local {
    struct Notification {
        let id: Int
        let type: Local.NotificationType
        let payload: NotificationPayloadModel
        let createdAt: Date
        var isRead: Bool
    }
    
    enum NotificationPayloadModel {
        case saerok(SaerokPayload)
        case announcement(AnnouncementPayload)
    }
    
    /// 새록 알림 페이로드
    struct SaerokPayload {
        let actorImageUrl: String
        let actorNickname: String
        let collectionId: Int
        let collectionImageUrl: String?
        let comment: String?
    }
    
    /// 공지사항 알림 페이로드
    struct AnnouncementPayload {
        let announcementId: Int?
        let body: String
    }
}

extension Local.Notification {
    init(from dto: DTO.Notification) throws {
        self.id = dto.id
        self.createdAt = DateFormatter.iso8601.date(from: dto.createdAt) ?? .now
        self.isRead = dto.isRead
        
        switch dto.type {
        case .likedOnCollection:
            self.type = .like
            self.payload = .saerok(
                .init(
                    actorImageUrl: dto.actorProfileImageUrl!,
                    actorNickname: dto.actorNickname!,
                    collectionId: dto.payload.collectionId!,
                    collectionImageUrl: dto.payload.collectionImageUrl,
                    comment: nil
                )
            )

        case .commentedOnCollection:
            self.type = .comment
            self.payload = .saerok(
                .init(
                    actorImageUrl: dto.actorProfileImageUrl!,
                    actorNickname: dto.actorNickname!,
                    collectionId: dto.payload.collectionId!,
                    collectionImageUrl: dto.payload.collectionImageUrl,
                    comment: dto.payload.comment
                )
            )
            
        case .repliedToComment:
            self.type = .replied
            self.payload = .saerok(
                .init(
                    actorImageUrl: dto.actorProfileImageUrl!,
                    actorNickname: dto.actorNickname!,
                    collectionId: dto.payload.collectionId!,
                    collectionImageUrl: dto.payload.collectionImageUrl,
                    comment: dto.payload.comment
                )
            )

        case .suggestedBirdIdOnCollection:
            self.type = .birdIdSuggestion
            self.payload = .saerok(
                .init(
                    actorImageUrl: dto.actorProfileImageUrl!,
                    actorNickname: dto.actorNickname!,
                    collectionId: dto.payload.collectionId!,
                    collectionImageUrl: dto.payload.collectionImageUrl,
                    comment: dto.payload.suggestedName
                )
            )
        case .systemPublishedAnnouncement:
            self.type = .system
            self.payload = .announcement(
                .init(
                    announcementId: dto.payload.announcementId,
                    body: dto.payload.inAppBody!
                )
            )
        }
    }
}

extension Array where Element == Local.Notification {
    init(from dto: DTO.NotificationResponse) {
        self = dto.items.compactMap { item in
            try? Local.Notification(from: item)
        }
    }
}
