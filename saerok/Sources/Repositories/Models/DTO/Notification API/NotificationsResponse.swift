//
//  NotificationsResponse.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import Foundation

extension DTO {
    struct NotificationResponse: Codable {
        let items: [Notification]
    }
    
    struct Notification: Codable, Identifiable {
        let id: Int
        let type: NotificationType
        let actorId: Int?
        let actorNickname: String?
        let actorProfileImageUrl: String?
        let payload: NotificationPayload
        let isRead: Bool
        let createdAt: String
    }
    
    enum NotificationType: String, Codable {
        case suggestedBirdIdOnCollection = "SUGGESTED_BIRD_ID_ON_COLLECTION"
        case likedOnCollection = "LIKED_ON_COLLECTION"
        case commentedOnCollection = "COMMENTED_ON_COLLECTION"
        case systemPublishedAnnouncement = "SYSTEM_PUBLISHED_ANNOUNCEMENT"
        case systemAdminMessage = "SYSTEM_ADMIN_MESSAGE"
        case repliedToComment = "REPLIED_TO_COMMENT"
    }
    
    struct NotificationPayload: Codable {
        // 새록
        let collectionId: Int?
        let commentId: Int?
        let suggestedName: String?
        let collectionImageUrl: String?
        let comment: String?
        
        // 공지사항
        let announcementId: Int?
        let body: String?
        let title: String?
        let inAppBody: String?
    }
}
