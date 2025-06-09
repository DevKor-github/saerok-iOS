//
//  EditCollectionMetadataRequest.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//

extension DTO {
    struct EditCollectionMetadataRequest: Codable {
        let isBirdIdUpdated: Bool?
        let birdId: Int?
        let discoveredDate: String?
        let longitude: Double?
        let latitude: Double?
        let locationAlias: String?
        let address: String?
        let note: String?
    }
}

