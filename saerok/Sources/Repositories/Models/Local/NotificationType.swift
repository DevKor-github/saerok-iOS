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
        case system = "SYSTEM_PUBLISHED_ANNOUNCEMENT"
        case adminMessage = "SYSTEM_ADMIN_MESSAGE"
        case replied = "REPLIED_TO_COMMENT"
        case freeBoardComment = "COMMENTED_ON_FREE_BOARD_POST"
        case freeBoardReply = "REPLIED_TO_FREE_BOARD_COMMENT"

        var title: String {
            switch self {
            case .like:
                return "좋아요 알림"
            case .comment:
                return "댓글 알림"
            case .replied:
                return "답글 알림"
            case .birdIdSuggestion:
                return "동정 의견 알림"
            case .system:
                return "공지사항 알림"
            case .adminMessage:
                return "관리자 알림"
            case .freeBoardComment:
                return "자유게시판 댓글 알림"
            case .freeBoardReply:
                return "자유게시판 답글 알림"
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
                case .systemPublishedAnnouncement:
                    dict[.system] = item.enabled
                case .repliedToComment:
                    dict[.replied] = item.enabled
                case .commentedOnFreeBoardPost:
                    dict[.freeBoardComment] = item.enabled
                case .repliedToFreeBoardComment:
                    dict[.freeBoardReply] = item.enabled
                case .systemAdminMessage:
                    break
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
