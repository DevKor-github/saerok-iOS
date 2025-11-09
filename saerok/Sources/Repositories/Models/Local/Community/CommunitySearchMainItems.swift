//
//  CommunitySearchMainItems.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


extension Local {
    struct CommunitySearchMainItems {
        let collections: [Local.CommunityItemSummary]
        let users: [Local.UserSummary]
        var collectionsCount: Int { collections.count }
        var usersCount: Int { users.count }
        var isEmpty: Bool { collections.isEmpty && users.isEmpty }
        
        init(collections: [Local.CommunityItemSummary], users: [Local.UserSummary]) {
            self.collections = collections
            self.users = users
        }
    }
}

extension Local.CommunitySearchMainItems {
    static func from(dto: DTO.CommunitySearchResponse) -> Self {
        return .init(
            collections: dto.collections.map { Local.CommunityItemSummary.from(dto: $0) },
            users: dto.users.map { Local.UserSummary.from(dto: $0) }
        )
    }
}
