//
//  FreeBoardPost.swift
//  saerok
//
//  Created by HanSeung on 5/5/26.
//

import Foundation

extension Local {
    struct FreeBoardPost: Identifiable, Equatable {
        let id: Int
        let userId: Int
        let nickname: String
        let profileImageUrl: String?
        let thumbnailProfileImageUrl: String?
        let content: String
        let commentCount: Int
        let isMine: Bool
        let createdAt: Date
        let updatedAt: Date
    }
}

extension Local.FreeBoardPost {
    static func from(dto: DTO.FreeBoardPostItem) -> Self {
        .init(
            id: dto.postId,
            userId: dto.userId,
            nickname: dto.nickname,
            profileImageUrl: dto.profileImageUrl,
            thumbnailProfileImageUrl: dto.thumbnailProfileImageUrl,
            content: dto.content,
            commentCount: dto.commentCount,
            isMine: dto.isMine,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
}
