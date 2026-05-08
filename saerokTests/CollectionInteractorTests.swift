import Testing
import Foundation
@testable import saerok

// MARK: - CollectionInteractor Tests

@Suite("CollectionInteractor")
struct CollectionInteractorTests {

    // MARK: fetchMyCollections

    @Test("fetchMyCollections: 최신순 정렬")
    func fetchMyCollectionsSortedByDate() async throws {
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository(
            summaries: [
                .stub(id: 1, createdAt: .init(timeIntervalSince1970: 1_000)),
                .stub(id: 2, createdAt: .init(timeIntervalSince1970: 3_000)),
                .stub(id: 3, createdAt: .init(timeIntervalSince1970: 2_000)),
            ]
        ))
        let collections = try await interactor.fetchMyCollections()
        let dates = collections.map(\.createdAt)
        #expect(dates == dates.sorted(by: >))
    }

    // MARK: editCollection

    @Test("editCollection: collectionID가 없으면 collectionNotFound 에러")
    func editCollectionThrowsWhenIdIsNil() async {
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository())
        let draft = Local.CollectionDraft(collectionID: nil)
        await #expect {
            try await interactor.editCollection(draft)
        } throws: { error in
            guard case CollectionInteractorError.collectionNotFound = error else { return false }
            return true
        }
    }

    // MARK: createCollection

    @Test("createCollection: image가 nil이면 invalidImageData 에러")
    func createCollectionThrowsWhenImageIsNil() async {
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository())
        let draft = Local.CollectionDraft(collectionID: nil)
        await #expect {
            try await interactor.createCollection(draft)
        } throws: { error in
            guard case CollectionInteractorError.invalidImageData = error else { return false }
            return true
        }
    }

    // MARK: fetchComments

    @Test("fetchComments: 차단 기능 비활성화 시 댓글 전체 반환")
    func fetchCommentsReturnsAllWhenBlockingIsDisabled() async throws {
        let stub = [Local.CollectionComment.stub(id: 1), .stub(id: 2), .stub(id: 3)]
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository(comments: stub))
        let result = try await interactor.fetchComments(1)
        #expect(result.count == 3)
    }

    // MARK: fetchLikeUsers

    @Test("fetchLikeUsers: DTO items를 Local.UserSummary로 올바르게 변환")
    func fetchLikeUsersMapsCorrectly() async throws {
        let likeUsers = DTO.CollectionLikeUsersResponse(items: [
            .init(userId: 10, nickname: "user10", profileImageUrl: ""),
            .init(userId: 20, nickname: "user20", profileImageUrl: ""),
        ])
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository(likeUsers: likeUsers))
        let result = try await interactor.fetchLikeUsers(1)
        #expect(result.count == 2)
        #expect(result[0].id == 10)
        #expect(result[1].id == 20)
    }

    // MARK: - Stub

    private struct StubCollectionRepository: CollectionRepository {
        var summaries: [Local.CollectionSummary] = []
        var comments: [Local.CollectionComment] = []
        var likeUsers: DTO.CollectionLikeUsersResponse = .init(items: [])

        func fetchCollectionSummaries() async throws -> [Local.CollectionSummary] { summaries }
        func fetchCollectionDetail(for id: Int) async throws -> Local.CollectionDetail { .mockData[0] }
        func createCollection(_ request: DTO.CreateCollectionRequest) async throws -> Int { 0 }
        func getPresignedURL(collectionId: Int, contentType: String) async throws -> DTO.PresignedURLResponse { .init(presignedUrl: "", objectKey: "") }
        func registerImageMetadata(collectionId: Int, request: DTO.RegisterImageRequest) async throws -> DTO.RegisterImageResponse { .init(imageId: 0, url: "") }
        func deleteCollection(_ id: Int) async throws {}
        func editCollection(id: Int, isBirdUpdated: Bool, _ draft: Local.CollectionDraft) async throws {}
        func fetchCollectionComments(_ id: Int) async throws -> [Local.CollectionComment] { comments }
        func createCollectionComment(id: Int, parentId: Int?, _ content: String) async throws {}
        func deleteCollectionComment(collectionId: Int, commentId: Int) async throws {}
        func toggleCollectionLike(_ id: Int) async throws -> Bool { false }
        func fetchLikeUsers(_ id: Int) async throws -> DTO.CollectionLikeUsersResponse { likeUsers }
        func reportCollection(_ id: Int) async throws {}
        func reportComment(_ collectionId: Int, commentId: Int) async throws {}
        func fetchBirdSuggestions(collectionId: Int) async throws -> [Local.BirdSuggestion] { [] }
        func suggestBird(collectionId: Int, birdId: Int) async throws {}
        func toggleSuggestionAgree(collectionId: Int, birdId: Int) async throws -> DTO.ToggleSuggestionResponse { .init(agreeCount: 0, disagreeCount: 0, isAgreedByMe: false, isDisagreedByMe: false) }
        func toggleSuggestionDisagree(collectionId: Int, birdId: Int) async throws -> DTO.ToggleSuggestionResponse { .init(agreeCount: 0, disagreeCount: 0, isAgreedByMe: false, isDisagreedByMe: false) }
        func adoptSuggestion(collectionId: Int, birdId: Int) async throws {}
        func resetSuggestion(collectionId: Int) async throws {}
    }
}

// MARK: - Test Helpers

private extension Local.CollectionSummary {
    static func stub(id: Int, createdAt: Date) -> Self {
        .init(
            id: 0,
            imageURL: nil,
            thumbnailImageURL: nil,
            birdName: nil,
            createdAt: createdAt
        )
    }
}

private extension Local.CollectionComment {
    static func stub(id: Int, userId: Int = 0) -> Self {
        .init(
            id: id,
            user: .init(id: userId, nickname: "user\(userId)", profileImageUrl: ""),
            content: "내용",
            likeCount: 0,
            isLiked: false,
            isMine: false,
            createdAt: .now,
            parentId: nil,
            replies: nil,
            isInteractive: true,
            isMyCollection: false
        )
    }
}
