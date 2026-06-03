//
//  SREndpoint+User.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - User API

extension SREndpoint {
    static func signUp_complete(body: DTO.SignUpRequest) -> SREndpoint {
        SREndpoint(
            path: "user/signup-complete",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true
        )
    }

    static func checkNickname(_ nickname: String) -> SREndpoint {
        SREndpoint(
            path: "user/check-nickname",
            query: ["nickname": nickname],
            response: DTO.CheckNicknameResponse.self
        )
    }

    static var me: SREndpoint {
        SREndpoint(path: "user/me", auth: .required, response: DTO.MeResponse.self)
    }

    static var deleteMe: SREndpoint {
        SREndpoint(path: "user/me", method: .delete, auth: .required)
    }

    static func updateMe(
        nickname: String? = nil,
        registerImage: DTO.ProfileRegisterImageRequest? = nil
    ) -> SREndpoint {
        let body: Data?
        if let nickname {
            body = jsonBody(["nickname": nickname])
        } else if let registerImage {
            body = jsonBody(registerImage)
        } else {
            body = nil
        }
        return SREndpoint(
            path: "user/me",
            method: .patch,
            auth: .required,
            body: body,
            json: true,
            response: DTO.MeResponse.self
        )
    }

    static var deleteProfileImage: SREndpoint {
        SREndpoint(path: "user/me/profile-image", method: .delete, auth: .required)
    }

    static func getProfilePresignedURL(contentType: String) -> SREndpoint {
        SREndpoint(
            path: "user/me/profile-image/presign",
            method: .post,
            auth: .required,
            body: jsonBody(["contentType": contentType]),
            json: true,
            response: DTO.PresignedURLResponse.self
        )
    }

    static func profile(userId: Int) -> SREndpoint {
        SREndpoint(path: "profile/\(userId)", response: DTO.ProfileResponse.self)
    }

    static func blockUser(body: DTO.BlockUserRequest) -> SREndpoint {
        SREndpoint(
            path: "users/blocks",
            method: .post,
            auth: .required,
            body: jsonBody(body),
            json: true
        )
    }
}
