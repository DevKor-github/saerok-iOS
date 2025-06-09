//
//  PresignedURLResponse.swift
//  saerok
//
//  Created by HanSeung on 6/7/25.
//


extension DTO {
    struct PresignedURLResponse: Decodable {
        let presignedUrl: String
        let objectKey: String
    }
}