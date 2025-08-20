//
//  SRAPIEndpoint.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import Foundation

enum SREndpoint: Endpoint {
    
    // MARK: Birds API
    
    case fullSync
    
    // MARK: Collections API
    
    case myCollections
    case collectionDetail(collectionId: Int)
    case nearbyCollections(lat: Double, lng: Double, radius: Double, isMineOnly: Bool, isGuest: Bool = false)
    case createCollection(body: DTO.CreateCollectionRequest)
    case getPresignedURL(collectionId: Int, contentType: String)
    case registerUploadedImage(collectionId: Int, body: DTO.RegisterImageRequest)
    case deleteCollection(collectionId: Int)
    case editCollection(collectionId: Int, body: DTO.EditCollectionMetadataRequest)
    case collectionComments(collectionId: Int)
    case createComment(collectionId: Int, body: DTO.CreateCommentRequest)
    case likeCollection(collectionId: Int)
    case deleteCollectionComment(collectionID: Int, commentID: Int)
    case reportCollection(collectionId: Int)
    
    // MARK: Bird ID Suggestions API
    
    case getSuggestions(collectionId: Int)
    case suggestBird(collectionId: Int, birdId: Int)
    case adoptSuggestion(collectionId: Int, birdId: Int)
    case toggleSuggestionAgree(collectionId: Int, birdId: Int)
    case toggleSuggestionDisagree(collectionId: Int, birdId: Int)
    case resetSuggestion(collectionId: Int)
    
    // MARK: Bookmark API
    
    case myBookmarks
    case toggleBookmark(birdId: Int)
    
    // MARK: Auth API
    
    case appleLogin(authorizationCode: String)
    case kakaoLogin(accessCode: String)
    case refreshToken(refreshToken: String)
    
    // MARK: User API
    
    case checkNickname(_ nickname: String)
    case me
    case updateMe(nickname: String? = nil, registerImage: DTO.ProfileRegisterImageRequest? = nil)
    case getProfilePresignedURL(contentType: String)
    
    // MARK: Notifications API
    
    case registerDeviceToken(body: DTO.RegisterDeviceTokenRequest)
    case getNotificationSettings(deviceId: String)
    case toggleNotificationSetting(body: DTO.ToggleNotificationRequest)
    case notifications
    case readAllNotifications
    case readNotification(notificationId: Int)
    case deleteAllNotifications
    case deleteNotification(_ notificationId: Int)
    case notificationsUnreadCount
}

extension SREndpoint {
    var baseURL: String {
        return "http://dev-api.saerok.app/api/v1/"
    }
    
//    var baseURL: String {
//        return "https://api.saerok.app/api/v1/"
//    }
//    
    var path: String {
        switch self {
        case .fullSync: "birds/full-sync"
        case .myCollections: "collections/me"
        case .collectionDetail(let collectionID), .deleteCollection(let collectionID): "collections/\(collectionID)"
        case .createCollection: "collections/"
        case .getPresignedURL(let collectionID, _): "collections/\(collectionID)/images/presign"
        case .registerUploadedImage(let collectionID, _): "collections/\(collectionID)/images"
        case .editCollection(let collectionID, _): "collections/\(collectionID)/edit"
        case .nearbyCollections: "collections/nearby"
        case .appleLogin: "auth/apple/login"
        case .kakaoLogin: "auth/kakao/login"
        case .refreshToken: "auth/refresh"
        case .checkNickname: "user/check-nickname"
        case .me, .updateMe: "user/me"
        case .getProfilePresignedURL: "user/me/profile-image/presign"
        case .toggleBookmark(let ID): "birds/bookmarks/\(ID)/toggle"
        case .myBookmarks: "birds/bookmarks/"
        case .collectionComments(let collectionID): "collections/\(collectionID)/comments"
        case .createComment(let collectionID, _): "collections/\(collectionID)/comments"
        case .likeCollection(collectionId: let collectionID): "collections/\(collectionID)/like"
        case .deleteCollectionComment(let collectionID, let commentID): "collections/\(collectionID)/comments/\(commentID)"
        case .reportCollection(let collectionId): "collections/\(collectionId)/report"
        case .getSuggestions(let collectionId): "collections/\(collectionId)/bird-id-suggestions"
        case .suggestBird(let collectionId, _): "collections/\(collectionId)/bird-id-suggestions"
        case .toggleSuggestionAgree(let collectionId, let birdId): "collections/\(collectionId)/bird-id-suggestions/\(birdId)/agree"
        case .toggleSuggestionDisagree(let collectionId, let birdId): "collections/\(collectionId)/bird-id-suggestions/\(birdId)/disagree"
        case .adoptSuggestion(let collectionId, let birdId): "collections/\(collectionId)/bird-id-suggestions/\(birdId)/adopt"
        case .resetSuggestion(collectionId: let collectionId): "/collections/\(collectionId)/bird-id-suggestions/all"
        case .registerDeviceToken: "notifications/tokens"
        case .getNotificationSettings: "notifications/settings"
        case .toggleNotificationSetting: "notifications/settings/toggle"
        case .notifications: "notifications"
        case .readAllNotifications: "notifications/read-all"
        case .readNotification(let notificationId): "notifications/\(notificationId)/read"
        case .deleteAllNotifications: "notifications/all"
        case .deleteNotification(let notificationId): "notifications/\(notificationId)"
        case .notificationsUnreadCount: "notifications/unread-count"
        }
    }
    
    var method: String {
        switch self {
        case .fullSync, .checkNickname, .me, .myCollections, .nearbyCollections, .collectionDetail, .myBookmarks, .collectionComments, .getSuggestions, .getNotificationSettings, .notifications, .notificationsUnreadCount: "GET"
        case .appleLogin, .kakaoLogin, .toggleBookmark, .refreshToken, .createCollection, .getPresignedURL, .registerUploadedImage, .createComment, .likeCollection, .suggestBird, .adoptSuggestion, .toggleSuggestionAgree, .toggleSuggestionDisagree, .reportCollection, .getProfilePresignedURL, .registerDeviceToken: "POST"
        case .updateMe, .editCollection, .toggleNotificationSetting, .readAllNotifications, .readNotification: "PATCH"
        case .deleteCollection, .deleteCollectionComment, .resetSuggestion, .deleteAllNotifications, .deleteNotification: "DELETE"
        }
    }
    
    var requiresAuth: Bool {
        if case let .nearbyCollections(_, _, _, _, isGuest) = self {
            return isGuest == false
        }
        switch self {
        case .toggleBookmark, .me, .updateMe, .myCollections, .collectionDetail, .createCollection, .getPresignedURL, .registerUploadedImage, .deleteCollection, .editCollection, .myBookmarks, .createComment, .deleteCollectionComment, .likeCollection, .collectionComments, .suggestBird, .adoptSuggestion, .toggleSuggestionAgree, .toggleSuggestionDisagree, .resetSuggestion, .reportCollection, .getProfilePresignedURL, .registerDeviceToken, .getNotificationSettings, .toggleNotificationSetting, .notifications, .readAllNotifications, .readNotification, .deleteAllNotifications, .deleteNotification, .notificationsUnreadCount:
            return true
        case .getSuggestions:
            return (try? KeyChain.read(key: .accessToken)) != nil
        default:
            return false
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        
        if requiresAuth {
            if let token = try? KeyChain.read(key: .accessToken) {
                headers["Authorization"] = "Bearer \(token)"
            }
        }
        
        switch self {
        case .appleLogin, .kakaoLogin, .refreshToken, .updateMe, .createCollection, .getPresignedURL, .registerUploadedImage, .editCollection, .createComment, .suggestBird, .getProfilePresignedURL, .registerDeviceToken, .toggleNotificationSetting:
            headers["Content-Type"] = "application/json"
        default:
            break
        }
        
        return headers.isEmpty ? nil : headers
    }
    
    var requestBody: Data? {
        switch self {
        case let .createCollection(body):
            return try? JSONEncoder().encode(body)
        case .getPresignedURL(_, let contentType):
            let body = ["contentType": "image/jpeg"]
            return try? JSONSerialization.data(withJSONObject: body)
        case .registerUploadedImage(_, let body):
            return try? JSONEncoder().encode(body)
        case.editCollection(_, let body):
            return try? JSONEncoder().encode(body)
        case .appleLogin(let authorizationCode):
            let body = ["authorizationCode": authorizationCode]
            return try? JSONSerialization.data(withJSONObject: body)
        case .kakaoLogin(let accessToken):
            let body = ["accessToken": accessToken]
            return try? JSONSerialization.data(withJSONObject: body)
        case .refreshToken(let token):
            let body = ["refreshTokenJson": token]
            return try? JSONSerialization.data(withJSONObject: body)
        case .updateMe(let nickname, let registerImage):
            if let nickname = nickname {
                let body = ["nickname": nickname]
                return try? JSONSerialization.data(withJSONObject: body)
            } else if let registerImage = registerImage {
                print(registerImage)
                return try? JSONEncoder().encode(registerImage)
            } else {
                return nil
            }
        case .createComment(_, let body):
            return try? JSONEncoder().encode(body)
        case .suggestBird(_, let birdId):
            let body = ["birdId": birdId]
            return try? JSONSerialization.data(withJSONObject: body)
        case .getProfilePresignedURL(let contentType):
            let body = ["contentType": contentType]
            return try? JSONSerialization.data(withJSONObject: body)
        case .registerDeviceToken(let body):
               return try? JSONEncoder().encode(body)
        case .toggleNotificationSetting(let body):
               return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
    
    var queryItems: [String: String]? {
        switch self {
        case .checkNickname(let nickname):
            return ["nickname": nickname]
        case .nearbyCollections(let lat, let lng, let radius, let isMineOnly, _):
            return [
                "latitude": "\(lat)",
                "longitude": "\(lng)",
                "radiusMeters": "\(radius)",
                "isMineOnly": "\(isMineOnly)"
            ]
        case .getNotificationSettings(let deviceId):
            return ["deviceId": deviceId]
        default:
            return nil
        }
    }
}

extension SREndpoint {
    var expectedResponseType: Decodable.Type {
        switch self {
        case .fullSync:
            return DTO.BirdsResponse.self
        case .myCollections:
            return DTO.MyCollectionsResponse.self
        case .collectionDetail:
            return DTO.CollectionDetailResponse.self
        case .createCollection:
            return DTO.CreateCollectionResponse.self
        case .getPresignedURL:
            return DTO.PresignedURLResponse.self
        case .registerUploadedImage:
            return DTO.RegisterImageResponse.self
        case .nearbyCollections:
            return DTO.NearbyCollectionsResponse.self
        case .deleteCollection:
            return EmptyResponse.self
        case .editCollection:
            return DTO.CollectionEditResponse.self
        case .appleLogin, .kakaoLogin, .refreshToken:
            return DTO.AuthResponse.self
        case .checkNickname:
            return DTO.CheckNicknameResponse.self
        case .me, .updateMe:
            return DTO.MeResponse.self
        case .toggleBookmark:
            return DTO.ToggleBookmarkResponse.self
        case .myBookmarks:
            return DTO.MyBookmarkResponse.self
        case .collectionComments:
            return DTO.CollectionCommentsResponse.self
        case .createComment:
            return DTO.CreateCommentResponse.self
        case .likeCollection:
            return DTO.CollectionLikeToggleResponse.self
        case .getSuggestions:
            return DTO.SuggestionListResponse.self
        case .suggestBird:
            return DTO.SuggestResponse.self
        case .adoptSuggestion:
            return DTO.AdoptSuggestionResponse.self
        case .toggleSuggestionAgree, .toggleSuggestionDisagree:
            return DTO.ToggleSuggestionResponse.self
        case .getProfilePresignedURL:
            return DTO.PresignedURLResponse.self
        case .registerDeviceToken:
            return DTO.RegisterDeviceTokenResponse.self
        case .getNotificationSettings:
            return DTO.GetNotificationSettingsResponse.self
        case .toggleNotificationSetting:
            return DTO.ToggleNotificationResponse.self
        case .notifications:
            return DTO.NotificationResponse.self
        case .notificationsUnreadCount:
            return DTO.GetUnreadCount.self
        default:
            return EmptyResponse.self
        }
    }
}
