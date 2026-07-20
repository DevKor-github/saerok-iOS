import Testing
import Foundation
@testable import saerok

// MARK: - FieldGuideInteractor Tests

@Suite("FieldGuideInteractor")
struct FieldGuideInteractorTests {

    // MARK: refreshFieldGuide — 동기화 조건

    @Test("도감 DB가 비어 있으면 최신 여부와 관계없이 서버 동기화를 수행한다")
    func refreshSyncsWhenEmpty() async throws {
        let spy = SpyBirdsRepository(isEmpty: true, isUpToDate: true)
        let interactor = FieldGuideInteractorImpl(repository: spy)
        try await interactor.refreshFieldGuide()
        #expect(spy.fetchAndStoreBirdsCallCount == 1)
    }

    @Test("도감 DB가 있고 최신 상태이면 서버 동기화를 생략한다")
    func refreshSkipsWhenNotEmptyAndUpToDate() async throws {
        let spy = SpyBirdsRepository(isEmpty: false, isUpToDate: true)
        let interactor = FieldGuideInteractorImpl(repository: spy)
        try await interactor.refreshFieldGuide()
        #expect(spy.fetchAndStoreBirdsCallCount == 0)
    }

    @Test("도감 DB가 있어도 서버에 변경 사항이 있으면 동기화를 수행한다")
    func refreshSyncsWhenOutdated() async throws {
        let spy = SpyBirdsRepository(isEmpty: false, isUpToDate: false)
        let interactor = FieldGuideInteractorImpl(repository: spy)
        try await interactor.refreshFieldGuide()
        #expect(spy.fetchAndStoreBirdsCallCount == 1)
    }

    // MARK: refreshFieldGuide — 에러 매핑

    @Test("동기화 중 Repository 에러가 발생하면 repositoryError로 감싸서 던진다")
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

    @Test("존재하지 않는 새의 상세를 조회하면 birdNotFound 에러를 던진다")
    @MainActor
    func loadBirdDetailsThrowsWhenNotFound() throws {
        let interactor = FieldGuideInteractorImpl(repository: SpyBirdsRepository(isEmpty: false, isUpToDate: true, bird: nil))
        #expect(throws: FieldGuideInteractorError.self) {
            _ = try interactor.loadBirdDetails(birdID: 99)
        }
    }

    @Test("존재하는 새의 상세를 조회하면 해당 새를 반환한다")
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
