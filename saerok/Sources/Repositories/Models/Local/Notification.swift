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
            self.payload = try Self.saerokPayload(from: dto, comment: nil)

        case .commentedOnCollection:
            self.type = .comment
            self.payload = try Self.saerokPayload(from: dto, comment: dto.payload.comment)

        case .repliedToComment:
            self.type = .replied
            self.payload = try Self.saerokPayload(from: dto, comment: dto.payload.comment)

        case .suggestedBirdIdOnCollection:
            self.type = .birdIdSuggestion
            self.payload = try Self.saerokPayload(from: dto, comment: dto.payload.suggestedName)

        case .systemPublishedAnnouncement:
            self.type = .system
            self.payload = .announcement(
                .init(
                    announcementId: dto.payload.announcementId,
                    body: dto.payload.inAppBody ?? dto.payload.body ?? ""
                )
            )
        case .systemAdminMessage:
            self.type = .adminMessage
            self.payload = .announcement(
                .init(
                    announcementId: nil,
                    body: dto.payload.body ?? ""
                )
            )
        }
    }

    private static func saerokPayload(from dto: DTO.Notification, comment: String?) throws -> Local.NotificationPayloadModel {
        guard let actorImageUrl = dto.actorProfileImageUrl else {
            throw NotificationMappingError.missingField("actorProfileImageUrl", notificationType: dto.type)
        }
        guard let actorNickname = dto.actorNickname else {
            throw NotificationMappingError.missingField("actorNickname", notificationType: dto.type)
        }
        guard let collectionId = dto.payload.collectionId else {
            throw NotificationMappingError.missingField("collectionId", notificationType: dto.type)
        }
        return .saerok(.init(
            actorImageUrl: actorImageUrl,
            actorNickname: actorNickname,
            collectionId: collectionId,
            collectionImageUrl: dto.payload.collectionImageUrl,
            comment: comment
        ))
    }
}

enum NotificationMappingError: Error {
    case missingField(String, notificationType: DTO.NotificationType)

    var localizedDescription: String {
        switch self {
        case .missingField(let field, let type):
            return "알림 매핑 실패: \(field) 필드 누락 (type: \(type))"
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
