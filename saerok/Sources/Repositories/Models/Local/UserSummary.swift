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
    }
}

extension Local.UserSummary {
    static func from(dto: DTO.CommunityItem.UserInfo?) -> Self {
        .init(
            id: dto?.userId ?? -1,
            nickname: dto?.nickname ?? "",
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
