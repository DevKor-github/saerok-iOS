//
//  CreateCollectionRequest.swift
//  saerok
//
//  Created by HanSeung on 6/7/25.
//


import Foundation

extension DTO {
    struct CreateCollectionRequest: Codable {
        let birdId: Int?
        let discoveredDate: String
        let latitude: Double
        let longitude: Double
        let locationAlias: String
        let address: String
        let note: String
        
        init(
            birdId: Int?,
            discoveredDate: Date,
            latitude: Double,
            longitude: Double,
            locationAlias: String,
            address: String,
            note: String
        ) {
            self.birdId = birdId
            self.discoveredDate = discoveredDate.toUploadType
            self.latitude = latitude
            self.longitude = longitude
            self.locationAlias = locationAlias
            self.address = address
            self.note = note
        }
    }
}
