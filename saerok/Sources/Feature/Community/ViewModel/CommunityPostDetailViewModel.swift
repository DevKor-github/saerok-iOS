//
//  CommunityPostDetailViewModel.swift
//  saerok
//
//  Created by Codex on 3/13/26.
//

import Foundation

extension CommunityPostDetailView {
    @Observable
    final class ViewModel {
        let post: DTO.Post
        private(set) var comments: [Local.CollectionComment]
        private(set) var isMyPost: Bool

        init(
            post: DTO.Post,
            comments: [Local.CollectionComment] = [],
            isMyPost: Bool = false
        ) {
            self.post = post
            self.comments = comments
            self.isMyPost = isMyPost
        }
    }
}

#if DEBUG
extension CommunityPostDetailView.ViewModel {
    static let mockComments: [Local.CollectionComment] = [
        .init(
            id: 1,
            user: .init(id: 101, nickname: "새록이", profileImageUrl: "https://picsum.photos/40"),
            content: "우와 자유게시판 너무 좋네요!",
            likeCount: 0,
            isLiked: false,
            isMine: false,
            createdAt: .now.addingTimeInterval(-3600),
            parentId: nil,
            replies: [
                .init(
                    id: 2,
                    user: .init(id: 102, nickname: "대댓글러", profileImageUrl: "https://picsum.photos/41"),
                    content: "맞아요! 자주 올게요.",
                    likeCount: 0,
                    isLiked: false,
                    isMine: false,
                    createdAt: .now.addingTimeInterval(-1800),
                    parentId: 1,
                    replies: nil,
                    isInteractive: true,
                    isMyCollection: false
                )
            ],
            isInteractive: true,
            isMyCollection: false
        ),
        .init(
            id: 3,
            user: .init(id: 103, nickname: "초보버드", profileImageUrl: "https://picsum.photos/42"),
            content: "오늘 본 새 이름 아시는 분?",
            likeCount: 0,
            isLiked: false,
            isMine: false,
            createdAt: .now.addingTimeInterval(-900),
            parentId: nil,
            replies: nil,
            isInteractive: true,
            isMyCollection: false
        )
    ]
}
#endif
