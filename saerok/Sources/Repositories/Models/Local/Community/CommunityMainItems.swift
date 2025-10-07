//
//  CommunityMainItems.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


extension Local {
    struct CommunityMainItems {
        let pendingCollections: [CommunityItemSummary]
        let recentCollections: [CommunityItemSummary]
        let popularCollections: [CommunityItemSummary]
        
        init(pendingCollections: [CommunityItemSummary], recentCollections: [CommunityItemSummary], popularCollections: [CommunityItemSummary]) {
            self.pendingCollections = pendingCollections
            self.recentCollections = recentCollections
            self.popularCollections = popularCollections
        }
                
        init() {
            self.pendingCollections = []
            self.recentCollections = []
            self.popularCollections = []
        }
    }
}

extension Local.CommunityMainItems {
    static func from(dto: DTO.CommunityMainResponse) -> Self {
        return .init(
            pendingCollections: dto.pendingCollections.map { Local.CommunityItemSummary.from(dto: $0) },
            recentCollections: dto.recentCollections.map { Local.CommunityItemSummary.from(dto: $0) },
            popularCollections: dto.popularCollections.map { Local.CommunityItemSummary.from(dto: $0) }
        )
    }
}
