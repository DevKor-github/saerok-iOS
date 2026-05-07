//
//  FreeBoardPostsResponse.swift
//  saerok
//
//  Created by HanSeung on 5/5/26.
//

import Foundation

extension DTO {
    struct CommunityFreeboardPostsResponse: Decodable {
        let items: [FreeBoardPostItem]
        let hasNext: Bool?
    }

    struct FreeBoardPostItem: Decodable {
        let postId: Int
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

    struct CreateFreeBoardPostRequest: Encodable {
        let content: String
    }

    struct CreateFreeBoardPostResponse: Decodable {
        let postId: Int
    }

    struct EditFreeBoardPostRequest: Encodable {
        let content: String
    }

    struct EditFreeBoardPostResponse: Decodable {
        let postId: Int
        let content: String
    }

    struct ReportFreeBoardPostResponse: Decodable {
        let reportId: Int
    }
}
