//
//  CollectionBird.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


import Foundation

extension DTO {
    struct CollectionBird: Codable {
        var birdId: String?
        var customName: String?
        var isIdentified: Bool
        var date: Date
        var latitude: Double
        var longitude: Double
        var locationDescription: String?
        var note: String?
        var imageURL: [String]
        var lastModified: Date
    }
}

extension DTO.CollectionBird {
//    func toModel() -> Local.CollectionBird {
//        Local.CollectionBird(
//            birdID: birdId.flatMap { Int($0) },
//            customName: customName,
//            date: date,
//            latitude: latitude,
//            longitude: longitude,
//            locationDescription: locationDescription,
//            note: note,
//            imageURL: imageURL,
//            lastModified: lastModified
//        )
//    }
}
