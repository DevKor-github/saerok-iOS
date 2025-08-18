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
    var joinedDate: Date
    var imageURL: String?
    
    init() {
        self.id = ""
        self.email = ""
        self.nickname = ""
        self.joinedDate = .now
        self.imageURL = ""
    }
    
    convenience init(nickname: String, email: String = "") {
        self.init()
        self.nickname = nickname
        self.email = email
    }
    
    convenience init(dto: DTO.MeResponse) {
        self.init()
        self.nickname = dto.nickname
        self.email = dto.email
        self.joinedDate = Date.fromSimpleDateString(dto.joinedDate ?? "2025-06-25") ?? .now
        self.imageURL = dto.profileImageUrl
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


extension User {
//    static let mock: User = .init(nickname: "하나관새록전문가")
}

