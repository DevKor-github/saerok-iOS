//
//  UserInteractor.swift
//  saerok
//
//  Created by HanSeung on 8/7/25.
//


import UIKit

protocol UserInteractor {
    func updateProfileImage(_ image: UIImage) async throws -> DTO.MeResponse
    func fetchNotifications() async throws -> [Local.NotificationItem]
    func fetchNotificationSetting() async throws -> Local.NotificationSettings
    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool
    func readNotification(_ id: Int) async throws
    func readAllNotification() async throws
    func deleteNotification(_ id: Int) async throws
    func deleteAllNotification() async throws
}

enum UserInteractorError: Error {
    case invalidImageData
}

struct UserInteractorImpl: UserInteractor {
    
    let repository: UserRepository
    
    private var deviceID: String { UserDefaults.standard.string(forKey: "deviceID") ?? "" }
    
    func updateProfileImage(_ image: UIImage) async throws -> DTO.MeResponse {
        guard let jpegData = image.resizedAndCompressed() else {
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
    
    func fetchNotifications() async throws -> [Local.NotificationItem] {
        return try await .init(from: repository.fetchNotifications())
    }
 
    func fetchNotificationSetting() async throws -> Local.NotificationSettings {
        let response: DTO.GetNotificationSettingsResponse = try await repository.fetchNotificationSetting(deviceID)
        return Local.NotificationSettings(from: response)
    }

    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool {
        let request: DTO.ToggleNotificationRequest = .init(deviceId: deviceID, type: type.rawValue)
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
}

struct MockUserInteractorImpl: UserInteractor {
    func deleteNotification(_ id: Int) async throws { }
    
    func fetchNotifications() async throws -> [Local.NotificationItem] { [] }
    
    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool { true }
    
    func fetchNotificationSetting() async throws -> Local.NotificationSettings { .init() }
    
    func updateProfileImage(_ image: UIImage) async throws -> DTO.MeResponse {
        .init(nickname: "", email: "", joinedDate: "", profileImageUrl: "")
    }
    
    func readNotification(_ id: Int) async throws { }
    
    func readAllNotification() async throws { }
    
    func deleteAllNotification() async throws { }
}
