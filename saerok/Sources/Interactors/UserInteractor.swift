//
//  UserInteractor.swift
//  saerok
//
//  Created by HanSeung on 8/7/25.
//


import UIKit

protocol UserInteractor {
    func createAccount(nickname: String) async throws
    func deleteAccount() async throws
    func updateProfileImage(_ image: UIImage) async throws -> DTO.MeResponse
    func deleteProfileImage() async throws
    func fetchNotifications() async throws -> [Local.NotificationItem]
    func fetchNotificationSetting() async throws -> Local.NotificationSettings
    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool
    func toggleAllNotificationSetting() async throws
    func readNotification(_ id: Int) async throws
    func readAllNotification() async throws
    func deleteNotification(_ id: Int) async throws
    func deleteAllNotification() async throws
    func hasUnreadNotifications() async throws -> Bool
    func fetchUserSummary(userID: Int) async throws -> Local.UserProfileSummary
}

enum UserInteractorError: Error {
    case invalidImageData
}

struct UserInteractorImpl: UserInteractor {
    
    let repository: UserRepository
    
    private var deviceID: String { TokenManager.shared.getDeviceId() }
    
    func createAccount(nickname: String) async throws {
        try await repository.createNewUser(nickname: nickname)
    }
    
    func deleteAccount() async throws {
        try await repository.deleteAccount()
        if let user = try await repository.getUser() {
            try await repository.deleteUser(user)
            TokenManager.shared.clearTokens()
        }
    }
    
    func updateProfileImage(_ image: UIImage) async throws -> DTO.MeResponse {
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
    
    func deleteProfileImage() async throws {
        _ = try await repository.deleteProfileImage()
    }

    func fetchNotifications() async throws -> [Local.NotificationItem] {
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

        let _ = try await (bird, comment, like)
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
    
    func hasUnreadNotifications() async throws -> Bool {
        return try await repository.getUnreadCount() == 0 ? false : true
    }
    
    func fetchUserSummary(userID: Int) async throws -> Local.UserProfileSummary {
        return try await .from(repository.getUserSummary(userID))
    }
}

struct MockUserInteractorImpl: UserInteractor {
    func deleteProfileImage() async throws { }
    
    func createAccount(nickname: String) async throws { }
    
    func deleteAccount() async throws { }

    func hasUnreadNotifications() async throws -> Bool { true }
    
    func deleteNotification(_ id: Int) async throws { }
    
    func fetchNotifications() async throws -> [Local.NotificationItem] { [] }
    
    func toggleNotificationSetting(_ type: Local.NotificationType) async throws -> Bool { true }
    
    func toggleAllNotificationSetting() async throws { }

    func fetchNotificationSetting() async throws -> Local.NotificationSettings { .init() }
    
    func updateProfileImage(_ image: UIImage) async throws -> DTO.MeResponse {
        .init(nickname: "", email: "", joinedDate: "", profileImageUrl: "")
    }
    
    func readNotification(_ id: Int) async throws { }
    
    func readAllNotification() async throws { }
    
    func deleteAllNotification() async throws { }
    
    func fetchUserSummary(userID: Int) async throws -> Local.UserProfileSummary { fatalError() }
}
