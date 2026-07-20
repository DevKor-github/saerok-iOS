import Testing
import Foundation
@testable import saerok

// MARK: - CollectionInteractor Tests

@Suite("CollectionInteractor")
struct CollectionInteractorTests {

    // MARK: fetchMyCollections

    @Test("내 컬렉션 목록을 조회하면 생성일 기준 최신순으로 정렬되어 반환된다")
    func fetchMyCollectionsSortedByDate() async throws {
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository(
            summaries: [
                .stub(id: 1, createdAt: .init(timeIntervalSince1970: 1_000)),
                .stub(id: 2, createdAt: .init(timeIntervalSince1970: 3_000)),
                .stub(id: 3, createdAt: .init(timeIntervalSince1970: 2_000)),
            ]
        ))
        let collections = try await interactor.fetchMyCollections()
        #expect(collections.map(\.id) == [2, 3, 1])
    }

    // MARK: editCollection

    @Test("컬렉션 ID가 없는 채로 수정을 요청하면 collectionNotFound 에러를 던진다")
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

    @Test("이미지가 없는 채로 컬렉션 생성을 요청하면 invalidImageData 에러를 던진다")
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

    @Test("차단 기능이 비활성화되어 있으면 댓글 목록 전체를 그대로 반환한다")
    func fetchCommentsReturnsAllWhenBlockingIsDisabled() async throws {
        let stub = [Local.CollectionComment.stub(id: 1), .stub(id: 2), .stub(id: 3)]
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository(comments: stub))
        let result = try await interactor.fetchComments(1)
        #expect(result.map(\.id) == [1, 2, 3])
    }

    // MARK: fetchLikeUsers

    @Test("좋아요 유저 목록을 조회하면 DTO 항목이 Local.UserSummary로 변환되어 반환된다")
    func fetchLikeUsersMapsCorrectly() async throws {
        let likeUsers = DTO.CollectionLikeUsersResponse(items: [
            .init(userId: 10, nickname: "user10", profileImageUrl: ""),
            .init(userId: 20, nickname: "user20", profileImageUrl: ""),
        ])
        let interactor = CollectionInteractorImpl(repository: StubCollectionRepository(likeUsers: likeUsers))
        let result = try await interactor.fetchLikeUsers(1)
        #expect(result.map(\.id) == [10, 20])
        #expect(result.map(\.nickname) == ["user10", "user20"])
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
            id: id,
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
