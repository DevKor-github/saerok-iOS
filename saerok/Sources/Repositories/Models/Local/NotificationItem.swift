import Foundation

extension Local {
    struct NotificationItem {
        let notificationId: Int
        let nickname: String
        let imageUrl: String
        let createdAt: Date
        let type: Local.NotificationType
        let collectionId: Int
        let content: String
        var isRead: Bool
    }
}

extension Local.NotificationItem {
    init(from dto: DTO.GetNotificationsResponse.Item) throws {
        self.notificationId = Int(dto.id)
        self.nickname = dto.actorNickname
        self.imageUrl = "" // 서버 응답에 이미지 url 없으므로 추후 매핑 필요
        self.createdAt = DateFormatter.iso8601.date(from: dto.createdAt) ?? .now
        self.type = {
            switch dto.type {
            case .likedOnCollection: return .like
            case .commentedOnCollection: return .comment
            case .suggestedBirdIdOnCollection: return .birdIdSuggestion
            }
        }()
        self.collectionId = dto.relatedId
        self.content = dto.body
        self.isRead = dto.isRead
    }
}

extension Array where Element == Local.NotificationItem {
    init(from dto: DTO.GetNotificationsResponse) {
        self = dto.items.compactMap { item in
            try? Local.NotificationItem(from: item)
        }
    }
}