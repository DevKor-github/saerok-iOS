//
//  ProfileResponse.swift
//  saerok
//
//  Created by HanSeung on 10/9/25.
//


import Foundation

extension DTO {
    struct ProfileResponse: Decodable {
        let nickname: String
        let joinedDate: String
        let profileImageUrl: String
        let collectionCount: Int
        let collections: [ProfileCollection]
    }

    struct ProfileCollection: Decodable {
        let collectionId: Int
        let birdId: Int?
        let birdKoreanName: String?
        let birdScientificName: String?
        let imageUrl: String
        let note: String?
        let discoveredDate: String
        let uploadedDate: String
    }
}
