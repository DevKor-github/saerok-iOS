//
//  MeResponse.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


extension DTO {
    struct MeResponse: Decodable {
        let nickname: String
        let email: String
    }
}
