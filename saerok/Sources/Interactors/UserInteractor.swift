//
//  UserInteractor.swift
//  saerok
//
//  Created by HanSeung on 8/7/25.
//

import Foundation

protocol UserInteractor {
    func signupComplete(nickname: String, source: SignUpSource) async throws
    func getUser() async throws -> User
    func deleteUser() async throws
    func deleteAccount() async throws
    func updateProfileImage(_ image: Data) async throws -> DTO.MeResponse
    func updateNickname(_ nickname: String) async throws
    func checkNicknameAvailability(_ nickname: String) async throws -> (Bool, String?)
    func deleteProfileImage() async throws
    func fetchNotifications() async throws -> [Local.Notification]
    func fetchNotificationSetting() async throws -> Local.NotificationSettings
    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool
    func toggleAllNotificationSetting() async throws
    func readNotification(_ id: Int) async throws
    func readAllNotification() async throws
    func deleteNotification(_ id: Int) async throws
    func deleteAllNotification() async throws
    func hasUnreadNotifications() async throws -> Bool
    func fetchUserSummary(userID: Int) async throws -> Local.UserProfileSummary
    func getAnnouncements() async throws -> [DTO.Announcement]
    func getAnnouncementDetail(_ id: Int) async throws -> DTO.AnnouncementDetail
    func registerDeviceToken(deviceID: String, fcmToken: String) async throws

    // 사용자 차단
    func blockUser(userId: Int) async throws
    func syncBlockable() async
    func isBlockable() -> Bool
}

enum UserInteractorError: Error {
    case invalidImageData
    case invalidUser
}

struct UserInteractorImpl: UserInteractor {
    typealias Error = UserInteractorError
    
    let repository: UserRepository
    
    private var deviceID: String { TokenManager.shared.getDeviceId() }
    
    func signupComplete(nickname: String, source: SignUpSource) async throws {
        try await repository.signUpComplete(nickname: nickname, source: source)
    }
    
    func getUser() async throws -> User {
        try await repository.getMeResponse()
    }
    
    func deleteUser() async throws {
        try await repository.deleteUser(nil)
    }
    
    func deleteAccount() async throws {
        try await repository.deleteAccount()
        // 서버 계정은 이미 삭제됐으므로, 로컬 정리 실패가 토큰 폐기를 막아선 안 된다
        try? await repository.deleteUser(nil)
        await TokenManager.shared.clearTokens()
    }
    
    func updateProfileImage(_ image: Data) async throws -> DTO.MeResponse {
        guard let jpegData = ImageUploadPreprocessor.prepareJPEGDataForUpload(from: image) else {
            throw UserInteractorError.invalidImageData
        }
        
        let presigned = try await repository.getProfilePresignedURL("image/jpeg")
        
        try await S3Uploader.uploadImage(to: presigned.presignedUrl, data: jpegData)
        
        let registerRequest = DTO.ProfileRegisterImageRequest(
            profileImageObjectKey: presigned.objectKey,
            profileImageContentType: "image/jpeg"
        )
        
        return try await repository.updateProfileImage(registerRequest)
    }
    
    func updateNickname(_ nickname: String) async throws {
        try await repository.updateNickname(nickname)
        guard let user = try await repository.getUser() else { throw Error.invalidUser }
        
        user.nickname = nickname
        try await repository.updateUser(to: user)
    }
    
    func checkNicknameAvailability(_ nickname: String) async throws -> (Bool, String?) {
        let result = try await repository.checkNicknameAvailability(nickname)
        
        return (result.isAvailable, result.reason)
    }

    func deleteProfileImage() async throws {
        _ = try await repository.deleteProfileImage()
    }

    func fetchNotifications() async throws -> [Local.Notification] {
        return try await .init(from: repository.fetchNotifications())
    }
 
    func fetchNotificationSetting() async throws -> Local.NotificationSettings {
        let response: DTO.GetNotificationSettingsResponse = try await repository.fetchNotificationSetting(deviceID)
        return Local.NotificationSettings(from: response)
    }
    
    func toggleAllNotificationSetting() async throws {
        async let bird = toggleNotificationSetting(.birdIdSuggestion)
        async let comment = toggleNotificationSetting(.comment)
        async let like = toggleNotificationSetting(.like)
        async let reply = toggleNotificationSetting(.replied)
        async let system = toggleNotificationSetting(.system)
        async let freeBoardComment = toggleNotificationSetting(.freeBoardComment)
        async let freeBoardReply = toggleNotificationSetting(.freeBoardReply)

        let _ = try await (bird, comment, like, reply, system, freeBoardComment, freeBoardReply)
    }

    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool {
        let request: DTO.ToggleNotificationRequest = .init(deviceId: deviceID, type: type.rawValue, platform: "IOS")
        return try await repository.toggleNotification(request).enabled
    }
    
    func readNotification(_ id: Int) async throws {
        try await repository.readNotification(id)
    }
    
    func readAllNotification() async throws {
        try await repository.readAllNotification()
    }
    
    func deleteNotification(_ id: Int) async throws {
        try await repository.deleteNotification(id)
    }

    func deleteAllNotification() async throws {
        try await repository.deleteAllNotification()
    }
    
    func hasUnreadNotifications() async throws -> Bool {
        try await repository.getUnreadCount() == 0 ? false : true
    }
    
    func fetchUserSummary(userID: Int) async throws -> Local.UserProfileSummary {
        try await .from(repository.getUserSummary(userID))
    }
    
    func getAnnouncements() async throws -> [DTO.Announcement] {
        try await repository.getAnnouncements().announcements
    }
    
    func getAnnouncementDetail(_ id: Int) async throws -> DTO.AnnouncementDetail {
        try await repository.getAnnouncementDetail(id)
    }
    
    func registerDeviceToken(deviceID: String, fcmToken: String) async throws {
        try await repository.registerDeviceToken(deviceID: deviceID, fcmToken: fcmToken)
    }

    func blockUser(userId: Int) async throws {
        storeBlockedUserId(userId)
        try await repository.blockUser(userId: userId)
    }
}

//사용자 차단
extension UserInteractorImpl {
    static let blockable = "blockable"

    func storeBlockedUserId(_ id: Int) {
        BlockedUserStorage.addBlockedUserId(id)
    }

    func readBlockedUserIds() -> [Int] {
        BlockedUserStorage.readBlockedUserIds()
    }
    
    func syncBlockable() async {
        do {
            try await repository.blockUser(userId: 0)
            UserDefaults.standard.set(true, forKey: Self.blockable)
        } catch {
            UserDefaults.standard.set(false, forKey: Self.blockable)
        }
        // TODO: - 사용자 차단 테스트
        #if DEBUG
        UserDefaults.standard.set(true, forKey: Self.blockable)
        #endif
    }
    
    func isBlockable() -> Bool {
        UserDefaults.standard.bool(forKey: Self.blockable)
    }
}

struct MockUserInteractorImpl: UserInteractor {
    func signupComplete(nickname: String, source: SignUpSource) async throws { }
    
    func checkNicknameAvailability(_ nickname: String) async throws -> (Bool, String?) { (false, nil) }
    
    func registerDeviceToken(deviceID: String, fcmToken: String) async throws { }

    // 사용자 차단
    func blockUser(userId: Int) async throws { }
    
    func syncBlockable() async {}
    
    func isBlockable() -> Bool { true }
    
    func getAnnouncements() async throws -> [DTO.Announcement] { [] }
    
    func getAnnouncementDetail(_ id: Int) async throws -> DTO.AnnouncementDetail {
        .init(id: 0, title: "", content: "", publishedAt: .now)
    }
    
    func deleteUser() async throws { }
    
    func getUser() async throws -> User { .init() }
    
    func updateUser(to user: User) async throws { }
    
    func updateNickname(_ nickname: String) async throws { }
    
    func deleteProfileImage() async throws { }
    
    func createAccount(nickname: String) async throws { }
    
    func deleteAccount() async throws { }

    func hasUnreadNotifications() async throws -> Bool { true }
    
    func deleteNotification(_ id: Int) async throws { }
    
    func fetchNotifications() async throws -> [Local.Notification] {
        let now = Date()
        return [
            .init(id: 1, type: .adminMessage,
                  payload: .announcement(.init(announcementId: nil, title: nil,
                      body: "안녕하세요! 새록 운영팀입니다. 이번 업데이트를 통해 댓글 기능이 추가되었습니다. 더 재미있는 새록으로 다른 사람들과 소통해보세요. 감사합니다.")),
                  createdAt: now.addingTimeInterval(-3 * 86400), isRead: false),
            .init(id: 2, type: .adminMessage,
                  payload: .announcement(.init(announcementId: nil, title: nil,
                      body: "'왜가리' 새록이 삭제되었어요. 참 아쉽네요!")),
                  createdAt: now.addingTimeInterval(-3 * 86400), isRead: true),
            .init(id: 3, type: .like,
                  payload: .saerok(.init(actorImageUrl: "", actorNickname: "비둘기짱",
                      collectionId: 1, collectionImageUrl: nil, commentId: nil, comment: nil)),
                  createdAt: now.addingTimeInterval(-600), isRead: false),
            .init(id: 4, type: .comment,
                  payload: .saerok(.init(actorImageUrl: "", actorNickname: "비둘기짱",
                      collectionId: 1, collectionImageUrl: nil, commentId: 1, comment: "새 잘 찍으셨네요.")),
                  createdAt: now.addingTimeInterval(-3 * 86400), isRead: false),
            .init(id: 5, type: .system,
                  payload: .announcement(.init(announcementId: 10, title: "공지사항",
                      body: "공지사항 내용입니다.")),
                  createdAt: now.addingTimeInterval(-3 * 86400), isRead: true),
        ]
    }
    
    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool { true }
    
    func toggleAllNotificationSetting() async throws { }

    func fetchNotificationSetting() async throws -> Local.NotificationSettings { .init() }
    
    func updateProfileImage(_ image: Data) async throws -> DTO.MeResponse {
        .init(nickname: "", email: "", joinedDate: "", profileImageUrl: "")
    }
    
    func readNotification(_ id: Int) async throws { }
    
    func readAllNotification() async throws { }
    
    func deleteAllNotification() async throws { }
    
    func fetchUserSummary(userID: Int) async throws -> Local.UserProfileSummary { fatalError() }
}
