//
//  RegisterImageRequest.swift
//  saerok
//
//  Created by HanSeung on 6/7/25.
//


extension DTO {
    struct RegisterImageRequest: Codable {
        let objectKey: String
        let contentType: String
    }

    struct RegisterImageResponse: Codable {
        let imageId: Int
        let url: String
    }
}
