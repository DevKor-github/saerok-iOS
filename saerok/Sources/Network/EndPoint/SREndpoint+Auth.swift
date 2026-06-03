//
//  SREndpoint+Auth.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Auth API

extension SREndpoint {
    static func appleLogin(authorizationCode: String) -> SREndpoint {
        SREndpoint(
            path: "auth/apple/login",
            method: .post,
            body: jsonBody(["authorizationCode": authorizationCode]),
            json: true,
            response: DTO.AuthResponse.self
        )
    }

    static func kakaoLogin(accessCode: String) -> SREndpoint {
        SREndpoint(
            path: "auth/kakao/login",
            method: .post,
            body: jsonBody(["accessToken": accessCode]),
            json: true,
            response: DTO.AuthResponse.self
        )
    }

    static func refreshToken(refreshToken: String) -> SREndpoint {
        SREndpoint(
            path: "auth/refresh",
            method: .post,
            body: jsonBody(["refreshTokenJson": refreshToken]),
            json: true,
            response: DTO.AuthResponse.self
        )
    }
}
