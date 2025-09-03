//
//  CollectionDetail.swift
//  saerok
//
//  Created by HanSeung on 5/30/25.
//


import Foundation
import UIKit

extension Local {
    struct CollectionDetail: Identifiable, Equatable {
        let id: Int
        let imageURL: String
        let discoveredDate: Date
        let coordinate: (latitude: Double, longitude: Double)
        let address: String
        let locationAlias: String
        let note: String
        let accessLevel: AccessLevel
        var likeCount: Int
        var isLiked: Bool
        var commentCount: Int
        let birdName: String?
        let birdID: Int?
        let scientificName: String?
        let userNickname: String
        let profileImageUrl: String
        
        mutating func likeToggle(_ isOn: Bool) {
            likeCount += isOn ? 1 : -1
            isLiked = isOn
        }
        
        static func == (lhs: Local.CollectionDetail, rhs: Local.CollectionDetail) -> Bool {
            lhs.id == rhs.id &&
            lhs.discoveredDate == rhs.discoveredDate &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.address == rhs.address &&
            lhs.locationAlias == rhs.locationAlias &&
            lhs.note == rhs.note &&
            lhs.accessLevel == rhs.accessLevel &&
            lhs.likeCount == rhs.likeCount &&
            lhs.isLiked == rhs.isLiked &&
            lhs.commentCount == rhs.commentCount &&
            lhs.birdName == rhs.birdName &&
            lhs.birdID == rhs.birdID &&
            lhs.scientificName == rhs.scientificName &&
            lhs.userNickname == rhs.userNickname &&
            lhs.profileImageUrl == rhs.profileImageUrl
        }
    }
    
    enum AccessLevel: String {
        case publicAccess = "PUBLIC"
        case privateAccess = "PRIVATE"
    }
}

extension Local.CollectionDetail {
    static func from(dto: DTO.CollectionDetailResponse) -> Local.CollectionDetail {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return .init(
            id: dto.collectionId,
            imageURL: dto.imageUrl ?? "",
            discoveredDate: formatter.date(from: dto.discoveredDate ?? "2025-06-19") ?? .now,
            coordinate: (dto.latitude, dto.longitude),
            address: dto.address ?? "",
            locationAlias: dto.locationAlias ?? "",
            note: dto.note,
            accessLevel: Local.AccessLevel(rawValue: dto.accessLevel.rawValue) ?? .publicAccess,
            likeCount: dto.likeCount,
            isLiked: dto.isLiked,
            commentCount: dto.commentCount,
            birdName: dto.bird.koreanName,
            birdID: dto.bird.birdId,
            scientificName: dto.bird.scientificName,
            userNickname: dto.user.nickname,
            profileImageUrl: dto.user.profileImageUrl
        )
    }
}

extension Local.CollectionDetail {
    static let mockData: [Local.CollectionDetail] = [
        .init(
            id: 1,
            imageURL: "",
            discoveredDate: Date(timeIntervalSince1970: 1_710_000_000),
            coordinate: (latitude: 37.5665, longitude: 126.9780),
            address: "서울 중구 세종대로 110 서울특별시청",
            locationAlias: "서울 시청",
            note: "도심 한가운데서 발견! 도심 한가운데서 발견! 도심 한가운데서 발견!",
            accessLevel: .publicAccess,
            likeCount: 5, isLiked: true, commentCount: 1,
            birdName: "가짜청딱따구리",
            birdID: 901,
            scientificName: "Cham Sae",
            userNickname: "",
            profileImageUrl: ""
        ),
    ]
}
