//
//  NotificationType.swift
//  saerok
//
//  Created by HanSeung on 8/12/25.
//


extension Local {
    enum NotificationType: String, Codable, CaseIterable {
        case like = "LIKED_ON_COLLECTION"
        case comment = "COMMENTED_ON_COLLECTION"
        case birdIdSuggestion = "SUGGESTED_BIRD_ID_ON_COLLECTION"
//        case system = "SYSTEM"
        
        var title: String {
            switch self {
            case .like:
                return "좋아요 알림"
            case .comment:
                return "댓글 알림"
            case .birdIdSuggestion:
                return "동정 의견 알림"
//            case .system:
//                return "새 기능 공지 알림"
            }
        }
    }
}

extension Local {
    struct NotificationSettings: Codable {
        var settings: [NotificationType: Bool]
        
        subscript(_ type: NotificationType) -> Bool {
            get { settings[type] ?? false }
            set { settings[type] = newValue }
        }
        
        init(from dto: DTO.GetNotificationSettingsResponse) {
            var dict: [NotificationType: Bool] = [:]
            
            for type in NotificationType.allCases {
                dict[type] = false
            }
            
            for item in dto.items {
                switch item.type {
                case .likedOnCollection:
                    dict[.like] = item.enabled
                case .commentedOnCollection:
                    dict[.comment] = item.enabled
                case .suggestedBirdIdOnCollection:
                    dict[.birdIdSuggestion] = item.enabled
                }
            }
            
            self.settings = dict
        }
        
        init() {
            self.settings = Dictionary(
                uniqueKeysWithValues: NotificationType.allCases.map { ($0, false) }
            )
        }
    }
}
