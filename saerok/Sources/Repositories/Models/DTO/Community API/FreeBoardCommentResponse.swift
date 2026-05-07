//
//  FreeBoardCommentResponse.swift
//  saerok
//
//  Created by HanSeung on 5/5/26.
//

import Foundation

extension DTO {
    struct FreeBoardCommentsResponse: Decodable {
        let items: [FreeBoardCommentItem]
        let isMyPost: Bool
        let hasNext: Bool?
    }

    struct FreeBoardCommentItem: Decodable {
        let commentId: Int
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
        let replies: [FreeBoardCommentItem]
    }

    struct CreateFreeBoardCommentRequest: Encodable {
        let content: String
        let parentId: Int?
    }

    struct CreateFreeBoardCommentResponse: Decodable {
        let commentId: Int
    }

    struct EditFreeBoardCommentRequest: Encodable {
        let content: String
    }

    struct EditFreeBoardCommentResponse: Decodable {
        let commentId: Int
        let content: String
    }

    struct FreeBoardCommentCountResponse: Decodable {
        let count: Int
    }
}
