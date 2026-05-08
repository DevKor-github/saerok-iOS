import Testing
import Foundation
@testable import saerok

// MARK: - UserInteractor Tests

@Suite("UserInteractor", .serialized)
struct UserInteractorTests {

    // MARK: hasUnreadNotifications

    @Test("hasUnreadNotifications: unreadCount가 0이면 false")
    func hasUnreadNotificationsReturnsFalseWhenZero() async throws {
        let interactor = UserInteractorImpl(repository: SpyUserRepository(unreadCount: 0))
        let result = try await interactor.hasUnreadNotifications()
        #expect(result == false)
    }

    @Test("hasUnreadNotifications: unreadCount가 0보다 크면 true")
    func hasUnreadNotificationsReturnsTrueWhenPositive() async throws {
        let interactor = UserInteractorImpl(repository: SpyUserRepository(unreadCount: 3))
        let result = try await interactor.hasUnreadNotifications()
        #expect(result == true)
    }

    // MARK: checkNicknameAvailability

    @Test("checkNicknameAvailability: isAvailable와 reason을 그대로 전달")
    func checkNicknameAvailabilityPassesThrough() async throws {
        let response = DTO.CheckNicknameResponse(isAvailable: true, reason: nil)
        let interactor = UserInteractorImpl(repository: SpyUserRepository(nicknameCheck: response))
        let (isAvailable, reason) = try await interactor.checkNicknameAvailability("새록유저")
        #expect(isAvailable == true)
        #expect(reason == nil)
    }

    @Test("checkNicknameAvailability: 사용 불가 사유도 그대로 전달")
    func checkNicknameAvailabilityPassesThroughReason() async throws {
        let response = DTO.CheckNicknameResponse(isAvailable: false, reason: "이미 사용 중인 닉네임입니다")
        let interactor = UserInteractorImpl(repository: SpyUserRepository(nicknameCheck: response))
        let (isAvailable, reason) = try await interactor.checkNicknameAvailability("중복닉네임")
        #expect(isAvailable == false)
        #expect(reason == "이미 사용 중인 닉네임입니다")
    }

    // MARK: blockUser

    @Test("blockUser: userId를 로컬 저장소에 저장하고 API를 호출")
    func blockUserStoresLocallyAndCallsAPI() async throws {
        let blockedUserIdsKey = "BlockedUserIds"
        defer { UserDefaults.standard.removeObject(forKey: blockedUserIdsKey) }

        let spy = SpyUserRepository()
        let interactor = UserInteractorImpl(repository: spy)
        try await interactor.blockUser(userId: 42)

        let stored = UserDefaults.standard.array(forKey: blockedUserIdsKey) as? [Int] ?? []
        #expect(stored.contains(42))
        #expect(spy.blockUserCalledWithId == 42)
    }

    @Test("blockUser: API 호출 전에 로컬 저장이 먼저 완료됨")
    func blockUserStoresBeforeAPICall() async throws {
        let blockedUserIdsKey = "BlockedUserIds"
        defer { UserDefaults.standard.removeObject(forKey: blockedUserIdsKey) }

        let spy = SpyUserRepository()
        let interactor = UserInteractorImpl(repository: spy)
        try await interactor.blockUser(userId: 99)

        #expect(spy.blockUserIdWasAlreadyStoredWhenCalled == true)
    }

    // MARK: - Spy

    private final class SpyUserRepository: UserRepository, @unchecked Sendable {
        var blockUserCalledWithId: Int?
        var blockUserIdWasAlreadyStoredWhenCalled = false
        private let unreadCount: Int
        private let nicknameCheck: DTO.CheckNicknameResponse

        init(
            unreadCount: Int = 0,
            nicknameCheck: DTO.CheckNicknameResponse = .init(isAvailable: true, reason: nil)
        ) {
            self.unreadCount = unreadCount
            self.nicknameCheck = nicknameCheck
        }

        func getUnreadCount() async throws -> Int { unreadCount }

        func checkNicknameAvailability(_ nickname: String) async throws -> DTO.CheckNicknameResponse { nicknameCheck }

        func blockUser(userId: Int) async throws {
            blockUserCalledWithId = userId
            let stored = UserDefaults.standard.array(forKey: "BlockedUserIds") as? [Int] ?? []
            blockUserIdWasAlreadyStoredWhenCalled = stored.contains(userId)
        }

        // 미사용 메서드 — 해당 테스트에서는 호출되지 않음
        private struct NotTestedError: Error {}
        func signUpComplete(nickname: String, source: SignUpSource) async throws { throw NotTestedError() }
        func createNewUser(nickname: String) async throws { throw NotTestedError() }
        func deleteAccount() async throws { throw NotTestedError() }
        func getProfilePresignedURL(_ contentType: String) async throws -> DTO.PresignedURLResponse { throw NotTestedError() }
        func updateProfileImage(_ request: DTO.ProfileRegisterImageRequest) async throws -> DTO.MeResponse { throw NotTestedError() }
        func updateNickname(_ nickname: String) async throws { throw NotTestedError() }
        func deleteProfileImage() async throws -> EmptyResponse { throw NotTestedError() }
        func fetchNotifications() async throws -> DTO.NotificationResponse { throw NotTestedError() }
        func fetchNotificationSetting(_ deviceID: String) async throws -> DTO.GetNotificationSettingsResponse { throw NotTestedError() }
        func toggleNotification(_ request: DTO.ToggleNotificationRequest) async throws -> DTO.ToggleNotificationResponse { throw NotTestedError() }
        func readNotification(_ id: Int) async throws { throw NotTestedError() }
        func readAllNotification() async throws { throw NotTestedError() }
        func deleteAllNotification() async throws { throw NotTestedError() }
        func deleteNotification(_ id: Int) async throws { throw NotTestedError() }
        func getUserSummary(_ id: Int) async throws -> DTO.ProfileResponse { throw NotTestedError() }
        func getMeResponse() async throws -> User { throw NotTestedError() }
        func getUser() async throws -> User? { throw NotTestedError() }
        func updateUser(to user: User) async throws { throw NotTestedError() }
        func deleteUser(_ user: User?) async throws { throw NotTestedError() }
        func getAnnouncements() async throws -> DTO.Announcements { throw NotTestedError() }
        func getAnnouncementDetail(_ id: Int) async throws -> DTO.AnnouncementDetail { throw NotTestedError() }
        func registerDeviceToken(deviceID: String, fcmToken: String) async throws { throw NotTestedError() }
    }
}
