//
//  UserSummary.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//


extension Local {
    struct UserSummary: Identifiable, Hashable {
        let id: Int
        let nickname: String
        let profileImageUrl: String
        
        init(id: Int, nickname: String, profileImageUrl: String) {
            self.id = id
            self.nickname = nickname
            self.profileImageUrl = profileImageUrl
        }
        
        init() {
            self.id = 0
            self.nickname = ""
            self.profileImageUrl = ""
        }
    }
}

extension Local.UserSummary {
    static func from(dto: DTO.CommunityItem.UserInfo?) -> Self {
        .init(
            id: dto?.userId ?? -1,
            nickname: dto?.nickname ?? "탈퇴한 사용자",
            profileImageUrl: dto?.profileImageUrl ?? ""
        )
    }
    
    static func from(dto: DTO.CommunitySearchUserItem) -> Self {
        .init(
            id: dto.userId,
            nickname: dto.nickname,
            profileImageUrl: dto.profileImageUrl
        )
    }
}
