//
//  CollectionDetailResponse.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


import Foundation

extension DTO {
    struct CollectionDetailResponse: Codable {
        let collectionId: Int
        let imageUrl: String?
        let discoveredDate: String?
        let latitude: Double
        let longitude: Double
        let address: String?
        let locationAlias: String?
        let note: String
        let accessLevel: AccessLevel
        let bird: BirdInfo
        let user: UserInfo
    }

    struct BirdInfo: Codable {
        let birdId: Int?
        let koreanName: String?
        let scientificName: String?
    }

    struct UserInfo: Codable {
        let userId: Int
        let nickname: String
    }

    enum AccessLevel: String, Codable {
        case publicAccess = "PUBLIC"
        case privateAccess = "PRIVATE"
    }
}
