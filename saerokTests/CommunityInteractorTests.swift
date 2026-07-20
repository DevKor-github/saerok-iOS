import Testing
@testable import saerok

// MARK: - CommunityInteractor Tests

@Suite("CommunityInteractor")
struct CommunityInteractorTests {

    // MARK: fetchMain

    @Test("커뮤니티 메인을 조회하면 동정대기·최신·인기 목록이 섞이지 않고 각각 반환된다")
    func fetchMainCombinesAllLists() async throws {
        let repo = StubCommunityRepository(
            pendingItems: [.stub(collectionId: 1)],
            recentItems: [.stub(collectionId: 2), .stub(collectionId: 3)],
            popularItems: [.stub(collectionId: 4)]
        )
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.fetchMain()

        #expect(result.pendingCollections.map(\.id) == [1])
        #expect(result.recentCollections.map(\.id) == [2, 3])
        #expect(result.popularCollections.map(\.id) == [4])
    }

    // MARK: fetchItems

    @Test("인기 타입으로 목록을 조회하면 인기 컬렉션 목록을 반환한다")
    func fetchItemsPopular() async throws {
        let repo = StubCommunityRepository(popularItems: [.stub(collectionId: 1), .stub(collectionId: 2)])
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.fetchItems(type: .popular, page: nil, size: nil)
        #expect(result.map(\.id) == [1, 2])
    }

    @Test("최신 타입으로 목록을 조회하면 최신 컬렉션 목록을 반환한다")
    func fetchItemsRecent() async throws {
        let repo = StubCommunityRepository(recentItems: [.stub(collectionId: 10)])
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.fetchItems(type: .recent, page: nil, size: nil)
        #expect(result.map(\.id) == [10])
    }

    @Test("동정 요청 타입으로 목록을 조회하면 동정 대기 컬렉션 목록을 반환한다")
    func fetchItemsSuggestion() async throws {
        let repo = StubCommunityRepository(pendingItems: [.stub(collectionId: 5), .stub(collectionId: 6), .stub(collectionId: 7)])
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.fetchItems(type: .suggestion, page: nil, size: nil)
        #expect(result.map(\.id) == [5, 6, 7])
    }

    @Test("게시판 타입으로 목록을 조회하면 빈 배열을 반환한다")
    func fetchItemsBoardReturnsEmpty() async throws {
        let interactor = CommunityInteractorImpl(repository: StubCommunityRepository())
        let result = try await interactor.fetchItems(type: .board, page: nil, size: nil)
        #expect(result.isEmpty)
    }

    // MARK: search

    @Test("전체 대상으로 검색하면 컬렉션과 유저를 모두 포함한 결과를 반환한다")
    func searchAllReturnsCombinedResult() async throws {
        let repo = StubCommunityRepository(
            searchCollections: [.stub(collectionId: 1)],
            searchUsers: [.stub(userId: 100)]
        )
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.search("test", searchCase: .all)

        #expect(result.collections.count == 1)
        #expect(result.users.count == 1)
    }

    @Test("컬렉션만 검색하면 유저 목록은 비어 있고 컬렉션 수만 집계된다")
    func searchCollectionSetsCorrectCounts() async throws {
        let repo = StubCommunityRepository(
            searchCollectionItems: [.stub(collectionId: 1), .stub(collectionId: 2)]
        )
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.search("test", searchCase: .collection)

        #expect(result.users.isEmpty)
        #expect(result.collectionsCount == 2)
        #expect(result.usersCount == 0)
    }

    @Test("유저만 검색하면 컬렉션 목록은 비어 있고 유저 수만 집계된다")
    func searchUserSetsCorrectCounts() async throws {
        let repo = StubCommunityRepository(
            searchUserItems: [.stub(userId: 1), .stub(userId: 2), .stub(userId: 3)]
        )
        let interactor = CommunityInteractorImpl(repository: repo)
        let result = try await interactor.search("test", searchCase: .user)

        #expect(result.collections.isEmpty)
        #expect(result.usersCount == 3)
        #expect(result.collectionsCount == 0)
    }

    // MARK: - Stub

    private struct StubCommunityRepository: CommunityRepository {
        var pendingItems: [DTO.CommunityItem] = []
        var recentItems: [DTO.CommunityItem] = []
        var popularItems: [DTO.CommunityItem] = []
        var searchCollections: [DTO.CommunityItem] = []
        var searchUsers: [DTO.CommunitySearchUserItem] = []
        var searchCollectionItems: [DTO.CommunityItem] = []
        var searchUserItems: [DTO.CommunitySearchUserItem] = []

        func fetchCommunityMain() async throws -> DTO.CommunityMainResponse {
            .init(recentCollections: recentItems, popularCollections: popularItems, pendingCollections: pendingItems, recentFreeBoardPosts: [])
        }
        func fetchPendingBirdId(page: Int?, size: Int?) async throws -> DTO.CommunityPendingBirdIdResponse { .init(items: pendingItems) }
        func fetchPopular(page: Int?, size: Int?) async throws -> DTO.CommunityPopularResponse { .init(items: popularItems) }
        func fetchRecent(page: Int?, size: Int?) async throws -> DTO.CommunityRecentResponse { .init(items: recentItems) }
        func search(query: String) async throws -> DTO.CommunitySearchResponse {
            .init(collectionsCount: searchCollections.count, collections: searchCollections, usersCount: searchUsers.count, users: searchUsers)
        }
        func searchUsers(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchUsersResponse { .init(items: searchUserItems) }
        func searchCollections(query: String, page: Int?, size: Int?) async throws -> DTO.CommunitySearchCollectionsResponse { .init(items: searchCollectionItems) }
        func fetchFreeboardPosts(page: Int?, size: Int?) async throws -> DTO.CommunityFreeboardPostsResponse { .init(items: [], hasNext: false) }
        func createFreeboardPost(content: String) async throws -> DTO.CreateFreeBoardPostResponse { .init(postId: 0) }
        func fetchFreeboardPost(postId: Int) async throws -> DTO.FreeBoardPostItem { fatalError("not used in these tests") }
        func deleteFreeboardPost(postId: Int) async throws {}
        func editFreeboardPost(postId: Int, content: String) async throws -> DTO.EditFreeBoardPostResponse { .init(postId: 0, content: "") }
        func fetchFreeboardComments(postId: Int, page: Int?, size: Int?) async throws -> DTO.FreeBoardCommentsResponse { .init(items: [], isMyPost: false, hasNext: false) }
        func createFreeboardComment(postId: Int, content: String, parentId: Int?) async throws -> DTO.CreateFreeBoardCommentResponse { .init(commentId: 0) }
        func deleteFreeboardComment(postId: Int, commentId: Int) async throws {}
        func editFreeboardComment(postId: Int, commentId: Int, content: String) async throws -> DTO.EditFreeBoardCommentResponse { .init(commentId: 0, content: "") }
        func fetchFreeboardCommentCount(postId: Int) async throws -> DTO.FreeBoardCommentCountResponse { .init(count: 0) }
        func reportFreeboardPost(postId: Int) async throws -> DTO.ReportFreeBoardPostResponse { .init(reportId: 0) }
    }
}

// MARK: - Test Helpers

private extension DTO.CommunityItem {
    static func stub(collectionId: Int, userId: Int = 0) -> Self {
        .init(
            collectionId: collectionId,
            imageUrl: nil,
            thumbnailImageUrl: nil,
            discoveredDate: "2024-01-01",
            createdAt: "2024-01-01T00:00:00Z",
            latitude: 0, longitude: 0,
            locationAlias: nil, address: nil, note: nil,
            likeCount: 0, commentCount: 0,
            isLiked: false, isPopular: false,
            bird: nil,
            user: .init(userId: userId, nickname: "user", profileImageUrl: ""),
            suggestionUserCount: nil
        )
    }
}

private extension DTO.CommunitySearchUserItem {
    static func stub(userId: Int) -> Self {
        .init(userId: userId, nickname: "user\(userId)", profileImageUrl: "")
    }
}
