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
        
        let parentId: Int?
        let replies: [Local.CollectionComment]?
        let isInteractive: Bool
        let isMyCollection: Bool
    }
}

extension Local.CollectionComment {
    static func from(dto: DTO.CollectionCommentsResponse) -> [Local.CollectionComment] {
        let isMyCollection = dto.isMyCollection
        
        return dto.items.map {
            Local.CollectionComment(
                id: $0.commentId,
                user: Local.UserSummary(
                    id: $0.userId,
                    nickname: $0.nickname ?? "탈퇴한 사용자",
                    profileImageUrl: $0.thumbnailProfileImageUrl
                ),
                content: $0.content,
                likeCount: $0.likeCount,
                isLiked: $0.isLiked,
                isMine: $0.isMine,
                createdAt: DateFormatter.iso8601.date(from: $0.createdAt) ?? .now,
                parentId: $0.parentId,
                replies: $0.replies?.map { reply in
                    Local.CollectionComment.reply(from: reply, isMyCollection: isMyCollection)
                },
                isInteractive: $0.status == "ACTIVE",
                isMyCollection: isMyCollection
            )
        }
    }
    
    private static func reply(
        from dto: DTO.CollectionCommentsResponse.Comment,
        isMyCollection: Bool
    ) -> Local.CollectionComment {
        Local.CollectionComment(
            id: dto.commentId,
            user: Local.UserSummary(
                id: dto.userId,
                nickname: dto.nickname ?? "탈퇴한 사용자",
                profileImageUrl: dto.thumbnailProfileImageUrl
            ),
            content: dto.content,
            likeCount: dto.likeCount,
            isLiked: dto.isLiked,
            isMine: dto.isMine,
            createdAt: DateFormatter.iso8601.date(from: dto.createdAt) ?? .now,
            parentId: dto.parentId,
            replies: nil,
            isInteractive: dto.status == "ACTIVE",
            isMyCollection: isMyCollection
        )
    }

    static func from(freeBoardComment: Local.FreeBoardComment, isMyPost: Bool) -> Self {
        .init(
            id: freeBoardComment.id,
            user: .init(
                id: freeBoardComment.userId,
                nickname: freeBoardComment.nickname,
                profileImageUrl: freeBoardComment.thumbnailProfileImageUrl ?? ""
            ),
            content: freeBoardComment.content,
            likeCount: 0,
            isLiked: false,
            isMine: freeBoardComment.isMine,
            createdAt: freeBoardComment.createdAt,
            parentId: freeBoardComment.parentId,
            replies: freeBoardComment.replies.isEmpty ? nil : freeBoardComment.replies.map {
                .from(freeBoardComment: $0, isMyPost: isMyPost)
            },
            isInteractive: freeBoardComment.status == "ACTIVE",
            isMyCollection: isMyPost
        )
    }
}
