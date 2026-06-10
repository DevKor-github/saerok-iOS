//
//  UserRepository.swift
//  saerok
//
//  Created by HanSeung on 8/7/25.
//

import SwiftData
import Foundation

protocol UserRepository {
    func signUpComplete(nickname: String, source: SignUpSource) async throws
    func createNewUser(nickname: String) async throws
    func deleteAccount() async throws
    func getProfilePresignedURL(_ contentType: String) async throws -> DTO.PresignedURLResponse
    func updateProfileImage(_ request: DTO.ProfileRegisterImageRequest) async throws -> DTO.MeResponse
    func updateNickname(_ nickname: String) async throws
    func checkNicknameAvailability(_ nickname: String) async throws -> DTO.CheckNicknameResponse
    func deleteProfileImage() async throws -> EmptyResponse
    func fetchNotifications() async throws -> DTO.NotificationResponse
    func fetchNotificationSetting(_ deviceID: String) async throws -> DTO.GetNotificationSettingsResponse
    func toggleNotification(_ request: DTO.ToggleNotificationRequest) async throws -> DTO.ToggleNotificationResponse
    func readNotification(_ id: Int) async throws
    func readAllNotification() async throws
    func deleteAllNotification() async throws
    func deleteNotification(_ id: Int) async throws
    func getUnreadCount() async throws -> Int
    func getUserSummary(_ id: Int) async throws -> DTO.ProfileResponse
    func getMeResponse() async throws -> User
    func getUser() async throws -> User?
    func updateUser(to user: User) async throws 
    func deleteUser(_ user: User?) async throws
    func getAnnouncements() async throws -> DTO.Announcements
    func getAnnouncementDetail(_ id: Int) async throws -> DTO.AnnouncementDetail
    func registerDeviceToken(deviceID: String, fcmToken: String) async throws
    func blockUser(userId: Int) async throws
}

extension MainRepository: UserRepository {
    func signUpComplete(nickname: String, source: SignUpSource) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .signUp_complete(body: .init(nickname: nickname, signupSource: source))
        )
        _ = try await getMeResponse()
    }

    func getMeResponse() async throws -> User {
        let userDTO: DTO.MeResponse = try await networkService.performSRRequest(.me)

        guard let nickname = userDTO.nickname, !nickname.isEmpty else {
            throw UserInteractorError.invalidUser
        }

        if let existing = try await getUser() {
            modelContext.delete(existing)
        }

        let newUser = User(dto: userDTO)
        modelContext.insert(newUser)
        try modelContext.save()
        return newUser
    }
    
    func createNewUser(nickname: String) async throws {
        let me: DTO.MeResponse = try await networkService.performSRRequest(
            .updateMe(nickname: nickname, registerImage: nil)
        )
        let user = User(dto: me)
        modelContext.insert(user)
        try modelContext.save()
    }
    
    func deleteAccount() async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .deleteMe
        )

        // 계정 귀속 데이터만 제거한다. 도메인 전체 삭제는 마이그레이션 플래그·온보딩 기록 등
        // 기기 단위 상태까지 초기화해 다음 사용자가 SwiftData 리셋/온보딩을 다시 겪게 된다.
        BlockedUserStorage.clear()
    }
    
    func getProfilePresignedURL(_ contentType: String) async throws -> DTO.PresignedURLResponse {
        return try await networkService.performSRRequest(
            .getProfilePresignedURL(contentType: contentType)
        )
    }
    
    func updateProfileImage(_ request: DTO.ProfileRegisterImageRequest) async throws -> DTO.MeResponse {
        return try await networkService.performSRRequest(
            .updateMe(registerImage: request)
        )
    }
    
    func updateNickname(_ nickname: String) async throws {
        let _: DTO.MeResponse = try await networkService.performSRRequest(.updateMe(nickname: nickname))
    }
    
    func checkNicknameAvailability(_ nickname: String) async throws -> DTO.CheckNicknameResponse {
        let result: DTO.CheckNicknameResponse = try await networkService.performSRRequest(
            .checkNickname(nickname)
        )
        
        return result
    }
    
    func deleteProfileImage() async throws -> EmptyResponse {
        try await networkService.performSRRequest(
            .deleteProfileImage
        )
    }
    
    func fetchNotifications() async throws -> DTO.NotificationResponse {
        try await networkService.performSRRequest(
            .notifications
        )
    }
    
    func fetchNotificationSetting(_ deviceID: String) async throws -> DTO.GetNotificationSettingsResponse {
        try await networkService.performSRRequest(
            .getNotificationSettings(deviceId: deviceID)
        )
    }
    
    func toggleNotification(_ request: DTO.ToggleNotificationRequest) async throws -> DTO.ToggleNotificationResponse {
        try await networkService.performSRRequest(
            .toggleNotificationSetting(body: request)
        )
    }
    
    func readNotification(_ id: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .readNotification(notificationId: id)
        )
    }
    
    func readAllNotification() async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .readAllNotifications
        )
    }
    
    func deleteAllNotification() async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .deleteAllNotifications
        )
    }
    
    func deleteNotification(_ id: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .deleteNotification(id)
        )
    }
    
    func getUnreadCount() async throws -> Int {
        let response: DTO.GetUnreadCount = try await networkService.performSRRequest(
            .notificationsUnreadCount
        )
        return response.unreadCount
    }
    
    func getUserSummary(_ id: Int) async throws -> DTO.ProfileResponse {
        let response: DTO.ProfileResponse = try await networkService.performSRRequest(
            .profile(userId: id)
        )
        return response
    }
    
    func updateUser(to user: User) async throws {
        if let existing = try await getUser() {
            existing.update(to: user)
            try modelContext.save()
        }
    }
    
    func getUser() async throws -> User? {
        let descriptor = FetchDescriptor<User>()
        return try modelContext.fetch(descriptor).first
    }
    
    func deleteUser(_ user: User? = nil) async throws {
        if let user = user {
            modelContext.delete(user)
        } else if let user = try await getUser() {
            modelContext.delete(user)
        }
        try modelContext.save()
    }
    
    func getAnnouncements() async throws -> DTO.Announcements {
        let response: DTO.Announcements = try await networkService.performSRRequest(
            .announcements
        )
        return response
    }
    
    func getAnnouncementDetail(_ id: Int) async throws -> DTO.AnnouncementDetail {
        let response: DTO.AnnouncementDetail = try await networkService.performSRRequest(
            .announcementDetail(id: id)
        )
        return response
    }
    
    func registerDeviceToken(deviceID: String, fcmToken: String) async throws {
        let _: DTO.RegisterDeviceTokenResponse = try await networkService.performSRRequest(
            .registerDeviceToken(body: .init(deviceId: deviceID, token: fcmToken, platform: "IOS"))
        )
    }

    func blockUser(userId: Int) async throws {
        let _: EmptyResponse = try await networkService.performSRRequest(
            .blockUser(body: .init(userId: userId))
        )
    }
}
