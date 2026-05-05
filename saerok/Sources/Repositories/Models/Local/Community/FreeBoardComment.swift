//
//  FreeBoardComment.swift
//  saerok
//
//  Created by HanSeung on 5/5/26.
//

import Foundation

extension Local {
    struct FreeBoardComment: Identifiable, Equatable {
        let id: Int
        let userId: Int
        let nickname: String
        let profileImageUrl: String?
        let thumbnailProfileImageUrl: String?
        let content: String
        let status: String
        let parentId: Int?
        let isMine: Bool
        let createdAt: Date
        let updatedAt: Date
        let replies: [FreeBoardComment]
    }
}

extension Local.FreeBoardComment {
    static func from(dto: DTO.FreeBoardCommentItem) -> Self {
        .init(
            id: dto.commentId,
            userId: dto.userId,
            nickname: dto.nickname,
            profileImageUrl: dto.profileImageUrl,
            thumbnailProfileImageUrl: dto.thumbnailProfileImageUrl,
            content: dto.content,
            status: dto.status,
            parentId: dto.parentId,
            isMine: dto.isMine,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            replies: dto.replies.map { .from(dto: $0) }
        )
    }
}
