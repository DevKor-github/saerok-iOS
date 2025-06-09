//
//  AuthResponse.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//

extension DTO {
    struct AuthResponse: Decodable {
        let accessToken: String
        let signupStatus: SignupStatus
        
        enum SignupStatus: String, Decodable {
            case completed = "COMPLETED"
            case profileRequired = "PROFILE_REQUIRED"
        }
    }
}
