//
//  CreateCommentRequest.swift
//  saerok
//
//  Created by HanSeung on 7/13/25.
//


extension DTO {
    struct CreateCommentRequest: Encodable {
        let content: String
        let parentId: Int?
    }

    struct CreateCommentResponse: Decodable {
        let commentId: Int
    }
}
