//
//  UpdateMeRequest.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


extension DTO {
    struct UpdateMeRequest: Encodable {
        let nickname: String
        let profileImageObjectKey: String
        let profileImageContentType: String
    }
}
