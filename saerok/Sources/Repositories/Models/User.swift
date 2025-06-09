//
//  User.swift
//  saerok
//
//  Created by HanSeung on 5/19/25.
//


import SwiftData
import Foundation

@Model
class User {
    @Attribute(.unique) var id: String
    var provider: SocialLoginProvider?
    var nickname: String
    var email: String
    var birthDate: Date?
    var startBirdingDate: Date?
    
    init() {
        self.id = ""
        self.email = ""
        self.nickname = ""
    }
}

extension User {
    enum Gender: String, Codable {
        case male
        case female
        case other
    }
    
    enum SocialLoginProvider: String, Codable {
        case apple
        case kakao
    }
}

