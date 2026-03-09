//
//  CollectionCommentsResponse.swift
//  saerok
//
//  Created by HanSeung on 7/13/25.
//

extension DTO {
    struct CollectionCommentsResponse: Decodable {
        let items: [Comment]
        let isMyCollection: Bool
        let hasNext: Bool?
        
        struct Comment: Decodable {
            let commentId: Int
            let userId: Int
            let nickname: String
            let profileImageUrl: String
            let thumbnailProfileImageUrl: String
            let content: String
            let status: String
            let parentId: Int?
            let likeCount: Int
            let isLiked: Bool
            let isMine: Bool
            let createdAt: String
            let updatedAt: String
            let replies: [Comment]?
        }
    }
}
