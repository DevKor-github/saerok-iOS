//
//  CommunityRepository.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//


import Foundation

protocol CommunityRepository {
    func fetchCommunityMain() async throws -> Local.CommunityMainItems
    func fetchCommunityDetail(type: CommunityType, page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]
    func search(query: String) async throws -> Local.CommunitySearchMainItems
    func searchUsers(query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems
    func searchCollections(query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems
}

extension MainRepository: CommunityRepository {
    func fetchCommunityMain() async throws -> Local.CommunityMainItems {
        let dto: DTO.CommunityMainResponse =  try await networkService.performSRRequest(.communityMain)
        return Local.CommunityMainItems.from(dto: dto)
    }
    
    func fetchCommunityDetail(type: CommunityType, page: Int? = nil, size: Int? = nil) async throws -> [Local.CommunityItemSummary] {
        switch type {
        case .popular:
            let dto: DTO.CommunityPopularResponse =
            try await networkService.performSRRequest(.communityPopular(page: page, size: size))
            return dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
            
        case .recent:
            let dto: DTO.CommunityRecentResponse =
            try await networkService.performSRRequest(.communityRecent(page: page, size: size))
            return dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
            
        case .suggestion:
            let dto: DTO.CommunityPendingBirdIdResponse =
            try await networkService.performSRRequest(.communityPendingBirdId(page: page, size: size))
            return dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
            
        case .board:
            return []
            
        case .search:
            return []
        }
    }

    func search(query: String) async throws -> Local.CommunitySearchMainItems {
        let dto: DTO.CommunitySearchResponse = try await networkService.performSRRequest(
            .communitySearch(query: query)
        )
        return .from(dto: dto)
    }
    
    func searchUsers(query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems {
        let dto: DTO.CommunitySearchUsersResponse = try await networkService.performSRRequest(
            .communitySearchUsers(query: query, page: page, size: size)
        )
        return .init(
            collections: [],
            users: dto.items.map {.from(dto: $0) },
            collectionsCount: 0,
            usersCount: dto.items.count
        )
    }
    
    func searchCollections(query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems {
        let dto: DTO.CommunitySearchCollectionsResponse = try await networkService.performSRRequest(
            .communitySearchCollections(query: query, page: page, size: size)
        )
        return .init(
            collections: dto.items.map { .from(dto: $0) },
            users: [],
            collectionsCount: dto.items.count,
            usersCount: 0
        )
    }
}
