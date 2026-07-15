import Testing
import Foundation
@testable import saerok

// MARK: - FieldGuideInteractor Tests

@Suite("FieldGuideInteractor")
struct FieldGuideInteractorTests {

    // MARK: refreshFieldGuide — 동기화 조건

    @Test("refreshFieldGuide: DB가 비어있으면 무조건 동기화")
    func refreshSyncsWhenEmpty() async throws {
        let spy = SpyBirdsRepository(isEmpty: true, isUpToDate: true)
        let interactor = FieldGuideInteractorImpl(repository: spy)
        try await interactor.refreshFieldGuide()
        #expect(spy.fetchAndStoreBirdsCallCount == 1)
    }

    @Test("refreshFieldGuide: DB가 있고 최신 상태이면 동기화 생략")
    func refreshSkipsWhenNotEmptyAndUpToDate() async throws {
        let spy = SpyBirdsRepository(isEmpty: false, isUpToDate: true)
        let interactor = FieldGuideInteractorImpl(repository: spy)
        try await interactor.refreshFieldGuide()
        #expect(spy.fetchAndStoreBirdsCallCount == 0)
    }

    @Test("refreshFieldGuide: DB가 있고 서버 변경이 있으면 동기화")
    func refreshSyncsWhenOutdated() async throws {
        let spy = SpyBirdsRepository(isEmpty: false, isUpToDate: false)
        let interactor = FieldGuideInteractorImpl(repository: spy)
        try await interactor.refreshFieldGuide()
        #expect(spy.fetchAndStoreBirdsCallCount == 1)
    }

    // MARK: refreshFieldGuide — 에러 매핑

    @Test("refreshFieldGuide: BirdsRepositoryError는 .repositoryError로 변환")
    func refreshMapsRepositoryError() async throws {
        let throwing = ThrowingBirdsRepository(error: .failedToSaveBirds)
        let interactor = FieldGuideInteractorImpl(repository: throwing)
        await #expect {
            try await interactor.refreshFieldGuide()
        } throws: { error in
            guard case FieldGuideInteractorError.repositoryError = error else { return false }
            return true
        }
    }

    // MARK: loadBirdDetails

    @Test("loadBirdDetails: 새가 없으면 birdNotFound 에러")
    @MainActor
    func loadBirdDetailsThrowsWhenNotFound() throws {
        let interactor = FieldGuideInteractorImpl(repository: SpyBirdsRepository(isEmpty: false, isUpToDate: true, bird: nil))
        #expect(throws: FieldGuideInteractorError.self) {
            _ = try interactor.loadBirdDetails(birdID: 99)
        }
    }

    @Test("loadBirdDetails: 새가 있으면 올바른 bird 반환")
    @MainActor
    func loadBirdDetailsReturnsBird() throws {
        let bird = Local.Bird.mockData
        let interactor = FieldGuideInteractorImpl(repository: SpyBirdsRepository(isEmpty: false, isUpToDate: true, bird: bird))
        let result = try interactor.loadBirdDetails(birdID: bird.id)
        #expect(result.id == bird.id)
    }

    // MARK: - Spy

    private final class SpyBirdsRepository: BirdsRepository, @unchecked Sendable {
        var fetchAndStoreBirdsCallCount = 0
        private let isEmpty: Bool
        private let isUpToDate: Bool
        private let bird: Local.Bird?

        init(isEmpty: Bool, isUpToDate: Bool, bird: Local.Bird? = nil) {
            self.isEmpty = isEmpty
            self.isUpToDate = isUpToDate
            self.bird = bird
        }

        @MainActor
        func birdDetail(for id: Int) throws -> Local.Bird? { bird }
        func fetchAndStoreBirds() async throws { fetchAndStoreBirdsCallCount += 1 }
        func checkUpToDate(_ date: Date) async throws -> Bool { isUpToDate }
        func checkIsBirdsEmpty() throws -> Bool { isEmpty }
        func syncBookmarks() async throws {}
        func toggleBookmark(for id: Int) async throws -> Bool { true }
        func fetchRecentBirdSearches() async throws -> [Local.RecentBirdSearch] { [] }
        func upsertRecentBirdSearch(birdID: Int) async throws {}
        func deleteRecentBirdSearch(id: UUID) async throws {}
    }

    private final class ThrowingBirdsRepository: BirdsRepository, @unchecked Sendable {
        private let error: BirdsRepositoryError

        init(error: BirdsRepositoryError) { self.error = error }

        @MainActor
        func birdDetail(for id: Int) throws -> Local.Bird? { nil }
        func fetchAndStoreBirds() async throws { throw error }
        func checkUpToDate(_ date: Date) async throws -> Bool { false }
        func checkIsBirdsEmpty() throws -> Bool { true }
        func syncBookmarks() async throws {}
        func toggleBookmark(for id: Int) async throws -> Bool { true }
        func fetchRecentBirdSearches() async throws -> [Local.RecentBirdSearch] { [] }
        func upsertRecentBirdSearch(birdID: Int) async throws {}
        func deleteRecentBirdSearch(id: UUID) async throws {}
    }
}
