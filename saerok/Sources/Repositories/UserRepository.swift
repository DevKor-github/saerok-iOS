//
//  UserRepository.swift
//  saerok
//
//  Created by HanSeung on 8/7/25.
//

protocol UserRepository {
    func getProfilePresignedURL(_ contentType: String) async throws -> DTO.PresignedURLResponse
    func updateProfileImage(_ request: DTO.ProfileRegisterImageRequest) async throws -> DTO.MeResponse
    func fetchNotifications() async throws -> DTO.NotificationResponse
    func fetchNotificationSetting(_ deviceID: String) async throws -> DTO.GetNotificationSettingsResponse
    func toggleNotification(_ request: DTO.ToggleNotificationRequest) async throws -> DTO.ToggleNotificationResponse
    func readNotification(_ id: Int) async throws
    func readAllNotification() async throws
    func deleteAllNotification() async throws
    func deleteNotification(_ id: Int) async throws
}

extension MainRepository: UserRepository {
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
    
    func fetchNotifications() async throws -> DTO.NotificationResponse {
        return try await networkService.performSRRequest(
            .notifications
        )
    }

    
    func fetchNotificationSetting(_ deviceID: String) async throws -> DTO.GetNotificationSettingsResponse {
        return try await networkService.performSRRequest(
            .getNotificationSettings(deviceId: deviceID)
        )
    }
    
    func toggleNotification(_ request: DTO.ToggleNotificationRequest) async throws -> DTO.ToggleNotificationResponse {
        return try await networkService.performSRRequest(
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
}
