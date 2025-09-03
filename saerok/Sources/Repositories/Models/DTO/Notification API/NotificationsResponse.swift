//
//  NotificationsResponse.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import Foundation

extension DTO {
    struct NotificationResponse: Codable {
        let items: [NotificationItem]
    }
    
    struct NotificationItem: Codable, Identifiable {
        let id: Int
        let type: NotificationType
        let actorId: Int
        let actorNickname: String
        let actorProfileImageUrl: String
        let payload: NotificationPayload
        let isRead: Bool
        let createdAt: String
    }
    
    enum NotificationType: String, Codable {
        case suggestedBirdIdOnCollection = "SUGGESTED_BIRD_ID_ON_COLLECTION"
        case likedOnCollection = "LIKED_ON_COLLECTION"
        case commentedOnCollection = "COMMENTED_ON_COLLECTION"
    }
    
    struct NotificationPayload: Codable {
        let collectionId: Int
        let suggestedName: String?
        let collectionImageUrl: String?
        let comment: String?
    }
}
