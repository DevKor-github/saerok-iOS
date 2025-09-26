//
//  CommunityPendingBirdIdResponse.swift
//  saerok
//
//  Created by Assistant on 9/23/25.
//


import Foundation

extension DTO {
    struct CommunityPendingBirdIdResponse: Decodable {
        let items: [CommunityItem]
    }
    
    struct CommunityPopularResponse: Decodable {
        let items: [CommunityItem]
    }
    
    struct CommunityRecentResponse: Decodable {
        let items: [CommunityItem]
    }
}
