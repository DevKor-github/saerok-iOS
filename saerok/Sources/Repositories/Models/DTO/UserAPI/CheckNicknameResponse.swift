//
//  CheckNicknameResponse.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


extension DTO {
    struct CheckNicknameResponse: Decodable {
        let isAvailable: Bool
        let reason: String?
    }
}
