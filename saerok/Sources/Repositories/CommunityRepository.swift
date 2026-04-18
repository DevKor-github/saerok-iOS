//
//  CommunityRepository.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//


import Foundation

protocol CommunityRepository {
    func fetchCommunityMain() async throws -> DTO.CommunityMainResponse
    func fetchPendingBirdId(page: Int?, size: Int?) async throws -> DTO.CommunityPendingBirdIdResponse
    func fetchPopular(page: Int?, size: Int?) async throws -> DTO.CommunityPopularResponse
    func fetchRecent(page: Int?, size: Int?) async throws -> DTO.CommunityRecentResponse
    func search(query: String) async throws -> DTO.CommunitySearchResponse
    func searchUsers(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchUsersResponse
    func searchCollections(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchCollectionsResponse
}

extension MainRepository: CommunityRepository {
    func fetchCommunityMain() async throws -> DTO.CommunityMainResponse {
        try await networkService.performSRRequest(.communityMain)
    }
    
    func fetchPendingBirdId(page: Int?, size: Int?) async throws -> DTO.CommunityPendingBirdIdResponse {
        try await networkService.performSRRequest(
            .communityPendingBirdId(page: page, size: size)
        )
    }
    
    func fetchPopular(page: Int?, size: Int?) async throws -> DTO.CommunityPopularResponse {
        try await networkService.performSRRequest(
            .communityPopular(page: page, size: size)
        )
    }
    
    func fetchRecent(page: Int?, size: Int?) async throws -> DTO.CommunityRecentResponse {
        try await networkService.performSRRequest(
            .communityRecent(page: page, size: size)
        )
    }
    
    func search(query: String) async throws -> DTO.CommunitySearchResponse {
        try await networkService.performSRRequest(
            .communitySearch(query: query)
        )
    }
    
    func searchUsers(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchUsersResponse {
        try await networkService.performSRRequest(
            .communitySearchUsers(query: query, page: page, size: size)
        )
    }
    
    func searchCollections(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchCollectionsResponse {
        try await networkService.performSRRequest(
            .communitySearchCollections(query: query, page: page, size: size)
        )
    }
}
