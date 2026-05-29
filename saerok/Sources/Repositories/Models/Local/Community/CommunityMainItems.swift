//
//  CommunityMainItems.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//

import Foundation

extension Local {
    struct FreeBoardPostSummary: Identifiable {
        let id: Int
        let userId: Int
        let nickname: String
        let thumbnailProfileImageUrl: String?
        let content: String
        let createdAt: Date
    }
}

extension Local {
    struct CommunityMainItems {
        let pendingCollections: [CommunityItemSummary]
        let recentCollections: [CommunityItemSummary]
        let popularCollections: [CommunityItemSummary]
        let recentFreeBoardPosts: [FreeBoardPostSummary]

        init(
            pendingCollections: [CommunityItemSummary],
            recentCollections: [CommunityItemSummary],
            popularCollections: [CommunityItemSummary],
            recentFreeBoardPosts: [FreeBoardPostSummary]
        ) {
            self.pendingCollections = pendingCollections
            self.recentCollections = recentCollections
            self.popularCollections = popularCollections
            self.recentFreeBoardPosts = recentFreeBoardPosts
        }

        init() {
            self.pendingCollections = []
            self.recentCollections = []
            self.popularCollections = []
            self.recentFreeBoardPosts = []
        }
    }
}

extension Local.CommunityMainItems {
    static func from(dto: DTO.CommunityMainResponse) -> Self {
        return .init(
            pendingCollections: dto.pendingCollections.map { Local.CommunityItemSummary.from(dto: $0) },
            recentCollections: dto.recentCollections.map { Local.CommunityItemSummary.from(dto: $0) },
            popularCollections: dto.popularCollections.map { Local.CommunityItemSummary.from(dto: $0) },
            recentFreeBoardPosts: dto.recentFreeBoardPosts.map {
                Local.FreeBoardPostSummary(
                    id: $0.postId,
                    userId: $0.userId,
                    nickname: $0.nickname,
                    thumbnailProfileImageUrl: $0.thumbnailProfileImageUrl,
                    content: $0.content,
                    createdAt: $0.createdAt
                )
            }
        )
    }
}
