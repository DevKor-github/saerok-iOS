//
//  UserRepository.swift
//  saerok
//
//  Created by HanSeung on 8/7/25.
//

import SwiftData
import Foundation

protocol UserRepository {
    func createNewUser(nickname: String) async throws
    func deleteAccount() async throws
    func getProfilePresignedURL(_ contentType: String) async throws -> DTO.PresignedURLResponse
    func updateProfileImage(_ request: DTO.ProfileRegisterImageRequest) async throws -> DTO.MeResponse
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
    func getUser() async throws -> User?
    func deleteUser(_ user: User) async throws
}

extension MainRepository: UserRepository {
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
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
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
    
    func getUser() async throws -> User? {
        let descriptor = FetchDescriptor<User>()
        return try modelContext.fetch(descriptor).first
    }
    
    func deleteUser(_ user: User) async throws {
        modelContext.delete(user)
    }
}
