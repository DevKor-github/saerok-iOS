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
        var collectionsCount: Int
        var usersCount: Int
        var isEmpty: Bool { collections.isEmpty && users.isEmpty }
        
        init(collections: [Local.CommunityItemSummary], users: [Local.UserSummary], collectionsCount: Int, usersCount: Int) {
            self.collections = collections
            self.users = users
            self.collectionsCount = collectionsCount
            self.usersCount = usersCount
        }
        
        init() {
            self.init(collections: [], users: [], collectionsCount: 0, usersCount: 0)
        }
    }
}

extension Local.CommunitySearchMainItems {
    static func from(dto: DTO.CommunitySearchResponse) -> Self {
        return .init(
            collections: dto.collections.map { Local.CommunityItemSummary.from(dto: $0) },
            users: dto.users.map { Local.UserSummary.from(dto: $0) },
            collectionsCount: dto.collectionsCount,
            usersCount: dto.usersCount
        )
    }
}
