//
//  CollectionEditResponse.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//


extension DTO {
    struct CollectionEditResponse: Codable {
        let collectionId: Int64
        let birdId: Int64?
        let discoveredDate: String
        let latitude: Double
        let longitude: Double
        let address: String
        let locationAlias: String
        let note: String
        let imageUrl: String
        let accessLevel: String
    }
}
