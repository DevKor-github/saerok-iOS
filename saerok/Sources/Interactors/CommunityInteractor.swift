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
    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardPost], hasNext: Bool)
    func createFreeboardPost(content: String) async throws -> Int
    func fetchFreeboardPost(postId: Int) async throws -> Local.FreeBoardPost
    func deleteFreeboardPost(postId: Int) async throws
    func editFreeboardPost(postId: Int, content: String) async throws -> (postId: Int, content: String)
    func fetchFreeboardComments(postId: Int, page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardComment], isMyPost: Bool, hasNext: Bool)
    func createFreeboardComment(postId: Int, content: String, parentId: Int?) async throws -> Int
    func deleteFreeboardComment(postId: Int, commentId: Int) async throws
    func editFreeboardComment(postId: Int, commentId: Int, content: String) async throws -> (commentId: Int, content: String)
    func fetchFreeboardCommentCount(postId: Int) async throws -> Int
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
        let items = Local.CommunityMainItems.from(dto: dto)
        return filterBlockedCollections(
            pending: items.pendingCollections,
            recent: items.recentCollections,
            popular: items.popularCollections
        )
    }
    
    func fetchItems(type: CommunityType, page: Int? = nil, size: Int? = nil) async throws -> [Local.CommunityItemSummary] {
        switch type {
        case .popular: try await fetchPopular(page: page, size: size)
        case .recent: try await fetchRecent(page: page, size: size)
        case .suggestion: try await fetchPending(page: page, size: size)
        case .search: fatalError("search case is not supported")
        #if DEBUG
        case .board:
            []
        #endif
        }
    }

    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardPost], hasNext: Bool) {
        let dto = try await repository.fetchFreeboardPosts(page: page, size: size)
        return (items: dto.items.map { Local.FreeBoardPost.from(dto: $0) }, hasNext: dto.hasNext)
    }

    func createFreeboardPost(content: String) async throws -> Int {
        let dto = try await repository.createFreeboardPost(content: content)
        return dto.postId
    }

    func fetchFreeboardPost(postId: Int) async throws -> Local.FreeBoardPost {
        let dto = try await repository.fetchFreeboardPost(postId: postId)
        return Local.FreeBoardPost.from(dto: dto)
    }

    func deleteFreeboardPost(postId: Int) async throws {
        try await repository.deleteFreeboardPost(postId: postId)
    }

    func editFreeboardPost(postId: Int, content: String) async throws -> (postId: Int, content: String) {
        let dto = try await repository.editFreeboardPost(postId: postId, content: content)
        return (postId: dto.postId, content: dto.content)
    }

    func fetchFreeboardComments(postId: Int, page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardComment], isMyPost: Bool, hasNext: Bool) {
        let dto = try await repository.fetchFreeboardComments(postId: postId, page: page, size: size)
        return (
            items: dto.items.map { Local.FreeBoardComment.from(dto: $0) },
            isMyPost: dto.isMyPost,
            hasNext: dto.hasNext
        )
    }

    func createFreeboardComment(postId: Int, content: String, parentId: Int?) async throws -> Int {
        let dto = try await repository.createFreeboardComment(postId: postId, content: content, parentId: parentId)
        return dto.commentId
    }

    func deleteFreeboardComment(postId: Int, commentId: Int) async throws {
        try await repository.deleteFreeboardComment(postId: postId, commentId: commentId)
    }

    func editFreeboardComment(postId: Int, commentId: Int, content: String) async throws -> (commentId: Int, content: String) {
        let dto = try await repository.editFreeboardComment(postId: postId, commentId: commentId, content: content)
        return (commentId: dto.commentId, content: dto.content)
    }

    func fetchFreeboardCommentCount(postId: Int) async throws -> Int {
        let dto = try await repository.fetchFreeboardCommentCount(postId: postId)
        return dto.count
    }

    func search(_ query: String, searchCase: CommunitySearchCase) async throws -> Local.CommunitySearchMainItems {
        switch searchCase {
        case .all:
            let dto = try await repository.search(query: query)
            return filterBlockedCollections(Local.CommunitySearchMainItems.from(dto: dto))
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
        let items = dto.items.map { Local.CommunityItemSummary.from(dto: $0) }
        let filtered = filterBlockedCollections(items)
        return .init(
            collections: filtered,
            users: [],
            collectionsCount: filtered.count,
            usersCount: 0
        )
    }
}

private extension CommunityInteractorImpl {
    func fetchPending(page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]  {
        let dto = try await repository.fetchPendingBirdId(page: page, size: size)
        return filterBlockedCollections(dto.items.map { Local.CommunityItemSummary.from(dto: $0) })
    }

    func fetchPopular(page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]  {
        let dto = try await repository.fetchPopular(page: page, size: size)
        return filterBlockedCollections(dto.items.map { Local.CommunityItemSummary.from(dto: $0) })
    }

    func fetchRecent(page: Int?, size: Int?) async throws -> [Local.CommunityItemSummary]  {
        let dto = try await repository.fetchRecent(page: page, size: size)
        return filterBlockedCollections(dto.items.map { Local.CommunityItemSummary.from(dto: $0) })
    }

    func filterBlockedCollections(_ items: [Local.CommunityItemSummary]) -> [Local.CommunityItemSummary] {
        guard isBlockableFilteringEnabled() else { return items }
        let blockedIds = Set(BlockedUserStorage.readBlockedUserIds())
        guard blockedIds.isEmpty == false else { return items }
        return items.filter { blockedIds.contains($0.user.id) == false }
    }

    func filterBlockedCollections(
        pending: [Local.CommunityItemSummary],
        recent: [Local.CommunityItemSummary],
        popular: [Local.CommunityItemSummary]
    ) -> Local.CommunityMainItems {
        .init(
            pendingCollections: filterBlockedCollections(pending),
            recentCollections: filterBlockedCollections(recent),
            popularCollections: filterBlockedCollections(popular)
        )
    }

    func filterBlockedCollections(_ items: Local.CommunitySearchMainItems) -> Local.CommunitySearchMainItems {
        guard isBlockableFilteringEnabled() else { return items }
        let filteredCollections = filterBlockedCollections(items.collections)
        return .init(
            collections: filteredCollections,
            users: items.users,
            collectionsCount: filteredCollections.count,
            usersCount: items.usersCount
        )
    }

    func isBlockableFilteringEnabled() -> Bool {
        BlockedUserStorage.isBlockable()
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

    func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardPost], hasNext: Bool) {
        throw CommunityInteractorError.notImplementedInMock
    }

    func createFreeboardPost(content: String) async throws -> Int {
        throw CommunityInteractorError.notImplementedInMock
    }

    func fetchFreeboardPost(postId: Int) async throws -> Local.FreeBoardPost {
        throw CommunityInteractorError.notImplementedInMock
    }

    func deleteFreeboardPost(postId: Int) async throws {
        throw CommunityInteractorError.notImplementedInMock
    }

    func editFreeboardPost(postId: Int, content: String) async throws -> (postId: Int, content: String) {
        throw CommunityInteractorError.notImplementedInMock
    }

    func fetchFreeboardComments(postId: Int, page: Int?, size: Int?) async throws -> (items: [Local.FreeBoardComment], isMyPost: Bool, hasNext: Bool) {
        throw CommunityInteractorError.notImplementedInMock
    }

    func createFreeboardComment(postId: Int, content: String, parentId: Int?) async throws -> Int {
        throw CommunityInteractorError.notImplementedInMock
    }

    func deleteFreeboardComment(postId: Int, commentId: Int) async throws {
        throw CommunityInteractorError.notImplementedInMock
    }

    func editFreeboardComment(postId: Int, commentId: Int, content: String) async throws -> (commentId: Int, content: String) {
        throw CommunityInteractorError.notImplementedInMock
    }

    func fetchFreeboardCommentCount(postId: Int) async throws -> Int {
        throw CommunityInteractorError.notImplementedInMock
    }

    func search(_ query: String, searchCase: CommunitySearchCase) async throws -> Local.CommunitySearchMainItems {
        throw CommunityInteractorError.notImplementedInMock
    }
}
