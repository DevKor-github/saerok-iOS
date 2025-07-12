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
    case updateMe(nickname: String)
}

extension SREndpoint {
    var baseURL: String {
        return "http://api.saerok.app/api/v1/"
    }
//    
//    var baseURL: String {
//        return "https://api.saerok.app/api/v1/"
//    }
//    
    var path: String {
        switch self {
        case .fullSync: "birds/full-sync"
        case .myCollections: "collections/me"
        case .collectionDetail(let collectionId), .deleteCollection(let collectionId): "collections/\(collectionId)"
        case .createCollection: "collections/"
        case .getPresignedURL(let collectionId, _): "collections/\(collectionId)/images/presign"
        case .registerUploadedImage(let collectionId, _): "collections/\(collectionId)/images"
        case .editCollection(let collectionId, _): "collections/\(collectionId)/edit"
        case .nearbyCollections: "collections/nearby"
        case .appleLogin: "auth/apple/login"
        case .kakaoLogin: "auth/kakao/login"
        case .refreshToken: "auth/refresh"
        case .checkNickname: "user/check-nickname"
        case .me, .updateMe: "user/me"
        case .toggleBookmark(let id): "birds/bookmarks/\(id)/toggle"
        case .myBookmarks: "birds/bookmarks/"
        }
    }
    
    var method: String {
        switch self {
        case .fullSync, .checkNickname, .me, .myCollections, .nearbyCollections, .collectionDetail, .myBookmarks: "GET"
        case .appleLogin, .kakaoLogin, .toggleBookmark, .refreshToken, .createCollection, .getPresignedURL, .registerUploadedImage: "POST"
        case .updateMe, .editCollection: "PATCH"
        case .deleteCollection: "DELETE"
        }
    }
    
    var requiresAuth: Bool {
        if case let .nearbyCollections(_, _, _, _, isGuest) = self {
            return isGuest == false
        }
        switch self {
        case .toggleBookmark, .me, .updateMe, .myCollections, .collectionDetail, .createCollection, .getPresignedURL, .registerUploadedImage, .deleteCollection, .editCollection, .myBookmarks:
            return true
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
        case .appleLogin, .kakaoLogin, .refreshToken, .updateMe, .createCollection, .getPresignedURL, .registerUploadedImage, .editCollection:
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
        case let .getPresignedURL(_, contentType):
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
        case .updateMe(let nickname):
            let body = ["nickname": nickname]
            return try? JSONSerialization.data(withJSONObject: body)
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
        }
    }
}

struct EmptyResponse: Decodable {}
