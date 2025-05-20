//
//  CollectionBird.swift
//  saerok
//
//  Created by HanSeung on 4/15/25.
//


import Foundation
import SwiftData
import UIKit

extension Local {
    @Model
    final class CollectionBird {
        @Attribute(.unique) var id: UUID
        var bird: Local.Bird?
        var customName: String?
        var date: Date
        var latitude: Double
        var longitude: Double
        var locationDescription: String?
        var note: String?
        var imageURL: [String]
        var lastModified: Date
        var imageData: [Data]

        var isIdentified: Bool {
            bird != nil
        }
        
        init(
            bird: Local.Bird?,
            customName: String?,
            date: Date,
            latitude: Double,
            longitude: Double,
            locationDescription: String?,
            note: String? ,
            imageURL: [String],
            lastModified: Date,
            images: [UIImage] = []
        ) {
            self.id = .init()
            self.bird = bird
            self.customName = customName
            self.date = date
            self.latitude = latitude
            self.longitude = longitude
            self.locationDescription = locationDescription
            self.note = note
            self.imageURL = imageURL
            self.lastModified = lastModified
            self.imageData = images.compactMap { image in
                image.jpegData(compressionQuality: 1.0) // JPEG 형식으로 변환
            }        }
        
    }
}

// MARK: - Convenience init

extension Local.CollectionBird {
    convenience init(
        bird: Local.Bird,
        date: Date = Date(),
        latitude: Double,
        longitude: Double,
        locationDescription: String? = nil,
        note: String? = nil,
        imageURL: [String] = [],
        lastModified: Date
    ) {
        self.init(
            bird: bird,
            customName: nil,
            date: date,
            latitude: latitude,
            longitude: longitude,
            locationDescription: locationDescription,
            note: note,
            imageURL: imageURL,
            lastModified: lastModified
        )
    }
    
    convenience init(
        customName: String,
        date: Date = Date(),
        latitude: Double,
        longitude: Double,
        locationDescription: String? = nil,
        note: String? = nil,
        imageURL: [String] = [],
        lastModified: Date
    ) {
        self.init(
            bird: nil,
            customName: customName,
            date: date,
            latitude: latitude,
            longitude: longitude,
            locationDescription: locationDescription,
            note: note,
            imageURL: imageURL,
            lastModified: lastModified
        )
    }
}

// MARK: - Mock Data

extension Local.CollectionBird {
    static let mockData: [Local.CollectionBird] = [
        .init(
            bird: .mockData[0],
            date: Date(),
            latitude: 37.5326,
            longitude: 126.9900,
            locationDescription: "서울 용산구 남산공원",
            note: "도토리 나무 근처에서 관찰됨",
            imageURL: [
                "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706182907626_U2GYB4NMS.jpg/ia82_327_i4.jpg?type=m1500",
                "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706182812680_DLGGIVRU8.jpg/ia82_327_i2.jpg?type=m1500",
            ],
            lastModified: Date()
        ),
        .init(
            bird: .mockData[1],
            date: Date(),
            latitude: 37.5300,
            longitude: 126.9970,
            locationDescription: "서울 용산구 이태원동",
            note: "카페 옥상 근처 전선에서 지저귐",
            imageURL: [
                "https://dbscthumb-phinf.pstatic.net/5041_000_1/20171207142615274_7IO0RPQAT.jpg/ib68_188_i3.jpg?type=m1500",
                "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706182923020_JG5PUWXDQ.jpg/ia82_328_i2.jpg?type=m1500"
            ],
            lastModified: Date()
        ),
        .init(
            bird: .mockData[2],
            date: Date(),
            latitude: 37.5285,
            longitude: 126.9668,
            locationDescription: "한강공원 이촌지구",
            note: "물가 근처 갈대밭에서 발견",
            imageURL: [
                "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706152059339_0WNI1C2F5.jpg/ia82_93_i4.jpg?type=m1500"
            ],
            lastModified: Date()
        ),
        .init(
            bird: .mockData[3],
            date: Date(),
            latitude: 37.5342,
            longitude: 126.9731,
            locationDescription: "서울 용산구 전쟁기념관 연못",
            note: "연못 근처 조용히 서 있었음",
            imageURL: [
                "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706175201747_5965PTVUI.jpg/ia82_278_i4.jpg?type=m1500"
            ],
            lastModified: Date()
        ),
    ]
}


