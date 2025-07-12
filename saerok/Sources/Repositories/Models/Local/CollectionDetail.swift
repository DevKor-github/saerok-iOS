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
        let birdName: String?
        let birdID: Int?
        let scientificName: String?
        let userNickname: String
        
        static func == (lhs: Local.CollectionDetail, rhs: Local.CollectionDetail) -> Bool {
            lhs.id == rhs.id &&
            lhs.imageURL == rhs.imageURL &&
            lhs.discoveredDate == rhs.discoveredDate &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.address == rhs.address &&
            lhs.locationAlias == rhs.locationAlias &&
            lhs.note == rhs.note &&
            lhs.accessLevel == rhs.accessLevel &&
            lhs.birdName == rhs.birdName &&
            lhs.birdID == rhs.birdID &&
            lhs.scientificName == rhs.scientificName &&
            lhs.userNickname == rhs.userNickname
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
            birdName: dto.bird.koreanName,
            birdID: dto.bird.birdId,
            scientificName: dto.bird.scientificName,
            userNickname: dto.user.nickname
        )
    }
}

extension Local.CollectionDetail {
    static let mockData: [Local.CollectionDetail] = [
        .init(
            id: 1,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706182907626_U2GYB4NMS.jpg/ia82_327_i4.jpg?type=m1500",
            discoveredDate: Date(timeIntervalSince1970: 1_710_000_000),
            coordinate: (latitude: 37.5665, longitude: 126.9780),
            address: "서울 중구 세종대로 110 서울특별시청",
            locationAlias: "서울 시청",
            note: "도심 한가운데서 발견!",
            accessLevel: .publicAccess,
            birdName: "가짜청딱따구리",
            birdID: 901,
            scientificName: "Cham Sae",
            userNickname: "bird_lover"
        ),
        .init(
            id: 2,
            imageURL: "https://dbscthumb-phinf.pstatic.net/5041_000_1/20171207142615274_7IO0RPQAT.jpg/ib68_188_i3.jpg?type=m1500",
            discoveredDate: Date(timeIntervalSince1970: 1_711_000_000),
            coordinate: (latitude: 33.4996, longitude: 126.5312),
            address: "서울 중구 세종대로 110 서울특별시청",
            locationAlias: "제주 곶자왈",
            note: "이렇게 가까이서 볼 줄이야!",
            accessLevel: .privateAccess,
            birdName: "가짜참새",
            birdID: 902,
            scientificName: "Zeby",
            userNickname: "skywatcher"
        ),
        .init(
            id: 3,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706175201747_5965PTVUI.jpg/ia82_278_i4.jpg?type=m1500",
            discoveredDate: Date(timeIntervalSince1970: 1_712_000_000),
            coordinate: (latitude: 35.1796, longitude: 129.0756),
            address: "서울 중구 세종대로 110 서울특별시청",
            locationAlias: "부산 해운대",
            note: "해변 근처에서 발견된 새",
            accessLevel: .publicAccess,
            birdName: "가짜참매",
            birdID: 903,
            scientificName: "Galmagie",
            userNickname: "marine_bird"
        ),
        .init(
            id: 4,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706152059339_0WNI1C2F5.jpg/ia82_93_i4.jpg?type=m1500",
            discoveredDate: Date(timeIntervalSince1970: 1_713_000_000),
            coordinate: (latitude: 37.4563, longitude: 126.7052),
            address: "서울 중구 세종대로 110 서울특별시청",
            locationAlias: "인천 송도 습지",
            note: "철새 도래지라더니 진짜다",
            accessLevel: .publicAccess,
            birdName: "가짜물총새",
            birdID: 904,
            scientificName: "whygari",
            userNickname: "wetland_explorer"
        ),
        .init(
            id: 5,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706175201747_5965PTVUI.jpg/ia82_278_i4.jpg?type=m1500",
            discoveredDate: Date(timeIntervalSince1970: 1_714_000_000),
            coordinate: (latitude: 36.3504, longitude: 127.3845),
            address: "서울 중구 세종대로 110 서울특별시청",
            locationAlias: "대전 유성천",
            note: "강변 따라 걷다가 우연히",
            accessLevel: .privateAccess,
            birdName: "가짜쇠백로",
            birdID: 905,
            scientificName: "baekro",
            userNickname: "casual_birder"
        )
    ]
}
