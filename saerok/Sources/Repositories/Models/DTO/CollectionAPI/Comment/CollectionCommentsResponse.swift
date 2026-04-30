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

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            isMyCollection = try container.decode(Bool.self, forKey: .isMyCollection)
            hasNext = try container.decodeIfPresent(Bool.self, forKey: .hasNext)
            items = try container.decode([Failable<Comment>].self, forKey: .items).compactMap(\.value)
        }

        private enum CodingKeys: String, CodingKey {
            case items, isMyCollection, hasNext
        }

        struct Comment: Decodable {
            let commentId: Int
            let userId: Int
            let nickname: String?
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

private struct Failable<T: Decodable>: Decodable {
    let value: T?
    init(from decoder: Decoder) throws {
        value = try? T(from: decoder)
    }
}
