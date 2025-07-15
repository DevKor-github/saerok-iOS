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
        let imageURL: String
        let userId: Int
        let nickname: String
        let content: String
        let likeCount: Int
        let isLiked: Bool
        let isMine: Bool
        let createdAt: Date
    }
}

extension Local.CollectionComment {
    static func from(dto: DTO.CollectionCommentsResponse) -> [Local.CollectionComment] {
        return dto.items.map { Local.CollectionComment(
            id: $0.commentId,
            imageURL: "",
            userId: $0.userId,
            nickname: $0.nickname,
            content: $0.content,
            likeCount: $0.likeCount,
            isLiked: $0.isLiked,
            isMine: $0.isMine,
            createdAt: DateFormatter.collectionComment.date(from: $0.createdAt) ?? .now
        )}
    }
}
