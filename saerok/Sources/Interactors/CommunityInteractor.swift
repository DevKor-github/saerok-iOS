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
        let dto = try await repository.fetchCommunityMain()
        return Local.CommunityMainItems.from(dto: dto)
    }
    
    func fetchItems(type: CommunityType, page: Int? = nil, size: Int? = nil) async throws -> [Local.CommunityItemSummary] {
        switch type {
        case .popular: try await fetchPopular(page: page, size: size)
        case .recent: try await fetchRecent(page: page, size: size)
        case .suggestion: try await fetchPending(page: page, size: size)
        case .search: fatalError("search case is not supported")
        }
    }
    
    func search(_ query: String, searchCase: CommunitySearchCase) async throws -> Local.CommunitySearchMainItems {
        switch searchCase {
        case .all:
            let dto = try await repository.search(query: query)
            return .from(dto: dto)
        case .collection:
            return try await searchCollections(query, page: nil, size: nil)
        case .user:
            return try await searchUsers(query, page: nil, size: nil)
        }
    }

    private func searchUsers(_ query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems {
        let dto = try await repository.searchUsers(query: query, page: page, size: size)
        return .init(
            collections: [],
            users: dto.items.map {.from(dto: $0) },
            collectionsCount: 0,
            usersCount: dto.items.count
        )
    }

    private func searchCollections(_ query: String, page: Int?, size: Int?) async throws -> Local.CommunitySearchMainItems {
        let dto = try await repository.searchCollections(query: query, page: page, size: size)
        return .init(
            collections: dto.items.map { .from(dto: $0) },
            users: [],
            collectionsCount: dto.items.count,
            usersCount: 0
        )
    }
}

private extension CommunityInteractorImpl {
    func fetchPending(page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]  {
        let dto = try await repository.fetchPendingBirdId(page: page, size: size)
        return dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
    }

    func fetchPopular(page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]  {
        let dto = try await repository.fetchPopular(page: page, size: size)
        return dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
    }

    func fetchRecent(page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]  {
        let dto = try await repository.fetchRecent(page: page, size: size)
        return dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
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
