//
//  CommunityInteractor.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//

import Foundation

protocol CommunityInteractor {
    func fetchMain() async throws -> Local.CommunityMainItems
    func fetchItems(type: CommunityType, page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]
    func search(_ query: String, searchCase: CommunitySearchCase) async throws -> Local.CommunitySearchMainItems
}

enum CommunityInteractorError: Error {
    case networkError(NetworkError)
    case unknownError(Error)
    case notImplementedInMock
}

struct CommunityInteractorImpl: CommunityInteractor {
    let repository: CommunityRepository

    init(repository: CommunityRepository) {
        self.repository = repository
    }

    func fetchMain() async throws -> Local.CommunityMainItems {
        try await repository.fetchCommunityMain()
    }
    
    func fetchItems(type: CommunityType, page: Int? = nil, size: Int? = nil) async throws -> [Local.CommunityItemSummary] {
        try await repository.fetchCommunityDetail(type: type, page: page, size: size)
    }
    
    func search(_ query: String, searchCase: CommunitySearchCase) async throws -> Local.CommunitySearchMainItems {
        switch searchCase {
        case .all:
            return try await repository.search(query: query)
        case .collection:
            return try await searchCollections(query, page: nil, size: nil)
        case .user:
            return try await searchUsers(query, page: nil, size: nil)
        }
    }

    private func searchUsers(_ query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems {
        return try await repository.searchUsers(query: query, page: page, size: size)
    }

    private func searchCollections(_ query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems {
        return try await repository.searchCollections(query: query, page: page, size: size)
    }
}

struct MockCommunityInteractorImpl: CommunityInteractor {
    init() {}

    func fetchMain() async throws -> Local.CommunityMainItems {
        Local.CommunityMainItems.init()
    }

    func fetchItems(type: CommunityType, page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary] {
        throw CommunityInteractorError.notImplementedInMock
    }
    
    func search(_ query: String, searchCase: CommunitySearchCase) async throws -> Local.CommunitySearchMainItems {
        throw CommunityInteractorError.notImplementedInMock
    }
}
