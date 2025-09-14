//
//  CollectionComments.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//


import Foundation

extension Local {
    struct CollectionComment: Identifiable, Hashable {
        let id: Int
        let user: UserSummary
        let content: String
        let likeCount: Int
        let isLiked: Bool
        let isMine: Bool
        let createdAt: Date
    }
}

extension Local.CollectionComment {
    static func from(dto: DTO.CollectionCommentsResponse) -> [Local.CollectionComment] {
        dto.items.map {
            Local.CollectionComment(
                id: $0.commentId,
                user: Local.UserSummary(
                    id: $0.userId,
                    nickname: $0.nickname,
                    profileImageUrl: $0.profileImageUrl
                ),
                content: $0.content,
                likeCount: $0.likeCount,
                isLiked: $0.isLiked,
                isMine: $0.isMine,
                createdAt: DateFormatter.iso8601.date(from: $0.createdAt) ?? .now
            )
        }
    }
}
