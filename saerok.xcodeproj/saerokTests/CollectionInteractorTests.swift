import Testing
@testable import saerok

// MARK: - CollectionInteractor Tests

@Suite("CollectionInteractor")
struct CollectionInteractorTests {

    // MARK: fetchMyCollections

    @Test("fetchMyCollections: 최신순 정렬")
    func fetchMyCollectionsSortedByDate() async throws {
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository())
        let collections = try await interactor.fetchMyCollections()
        let dates = collections.map(\.createdAt)
        #expect(dates == dates.sorted(by: >), "최신 항목이 먼저 정렬되어야 합니다")
    }

    // MARK: Stub Repository

    private struct StubCollectionRepository: CollectionRepository {
        func fetchCollectionSummaries() async throws -> [Local.CollectionSummary] {
            [
                .stub(id: 1, createdAt: .init(timeIntervalSince1970: 1_000)),
                .stub(id: 2, createdAt: .init(timeIntervalSince1970: 3_000)),
                .stub(id: 3, createdAt: .init(timeIntervalSince1970: 2_000)),
            ]
        }

        // 사용되지 않는 stub 메서드 — 컴파일 통과용
        func fetchCollectionDetail(for id: Int) async throws -> Local.CollectionDetail { .mockData[0] }
        func createCollection(_ dto: DTO.CreateCollectionRequest) async throws -> DTO.CreateCollectionResponse { .init(collectionId: 0) }
        func deleteCollection(_ id: Int) async throws {}
        func editCollection(id: Int, isBirdUpdated: Bool, _ draft: Local.CollectionDraft) async throws {}
        func fetchCollectionComments(_ id: Int) async throws -> [Local.CollectionComment] { [] }
        func createCollectionComment(id: Int, parentId: Int?, _ content: String) async throws {}
        func deleteCollectionComment(collectionId: Int, commentId: Int) async throws {}
        func toggleCollectionLike(_ id: Int) async throws -> Bool { false }
        func fetchLikeUsers(_ id: Int) async throws -> DTO.LikeUsersResponse { .init(items: []) }
        func reportCollection(_ id: Int) async throws {}
        func reportComment(_ collectionId: Int, commentId: Int) async throws {}
        func getPresignedURL(collectionId: Int, contentType: String) async throws -> DTO.PresignedURLResponse { .init(presignedUrl: "", objectKey: "") }
        func registerImageMetadata(collectionId: Int, request: DTO.RegisterImageRequest) async throws -> DTO.RegisterImageResponse { .init() }
        func fetchBirdSuggestions(collectionId: Int) async throws -> [Local.BirdSuggestion] { [] }
        func suggestBird(collectionId: Int, birdId: Int) async throws {}
        func toggleSuggestionAgree(collectionId: Int, birdId: Int) async throws -> DTO.SuggestionVoteResponse { .init() }
        func toggleSuggestionDisagree(collectionId: Int, birdId: Int) async throws -> DTO.SuggestionVoteResponse { .init() }
        func adoptSuggestion(collectionId: Int, birdId: Int) async throws {}
        func resetSuggestion(collectionId: Int) async throws {}
    }
}

// MARK: - Test Helpers

private extension Local.CollectionSummary {
    static func stub(id: Int, createdAt: Date) -> Self {
        .init(
            id: id,
            imageURL: "",
            birdName: nil,
            locationAlias: "",
            likeCount: 0,
            commentCount: 0,
            isLiked: false,
            createdAt: createdAt
        )
    }
}
