//
//  CommunityCollectionSummary.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


import Foundation

extension Local {
    struct CommunityItemSummary: Identifiable, Equatable {
        let id: Int
        let imageURL: String?
        let discoveredDate: Date?
        let latitude: Double
        let longitude: Double
        let locationAlias: String
        let address: String?
        let note: String
        let likeCount: Int
        let commentCount: Int
        let isLiked: Bool
        let birdId: Int?
        let birdName: String?
        let user: UserSummary
        let suggestionUserCount: Int?
    }
}

extension Local.CommunityItemSummary {
    static func from(dto: DTO.CommunityItem) -> Self {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .init(secondsFromGMT: 0)
        let date: Date = formatter.date(from: dto.discoveredDate) ?? .now
        
        return .init(
            id: dto.collectionId,
            imageURL: dto.imageUrl,
            discoveredDate: date,
            latitude: dto.latitude,
            longitude: dto.longitude,
            locationAlias: dto.locationAlias ?? "",
            address: dto.address,
            note: dto.note ?? "",
            likeCount: dto.likeCount,
            commentCount: dto.commentCount,
            isLiked: dto.isLiked,
            birdId: dto.bird?.birdId,
            birdName: dto.bird?.koreanName,
            user: .from(dto: dto.user),
            suggestionUserCount: dto.suggestionUserCount
        )
    }
}

extension Local.CommunityItemSummary {
    // Standard mock items (suggestionUserCount = nil)
    static let mock1: Local.CommunityItemSummary = .init(
        id: 1,
        imageURL: "https://cdn.example.com/collection-images/1.jpg",
        discoveredDate: Date(timeIntervalSince1970: 1_700_000_000),
        latitude: 37.54321,
        longitude: 127.01234,
        locationAlias: "서울숲",
        address: "서울시 성동구 성수동",
        note: "서울숲에서 까치를 봤어요",
        likeCount: 15,
        commentCount: 7,
        isLiked: true,
        birdId: 1,
        birdName: "까치",
        user: Local.UserSummary(
            id: 10,
            nickname: "안암동새록마스터",
            profileImageUrl: "https://cdn.example.com/user-profile-images/10.jpg"
        ),
        suggestionUserCount: nil
    )

    static let mock2: Local.CommunityItemSummary = .init(
        id: 2,
        imageURL: "https://cdn.example.com/collection-images/2.jpg",
        discoveredDate: Date(timeIntervalSince1970: 1_705_000_000),
        latitude: 37.5665,
        longitude: 126.9780,
        locationAlias: "광화문",
        address: "서울특별시 종로구",
        note: "비 오는 날 참새가 처마 밑에서 쉬고 있었어요",
        likeCount: 8,
        commentCount: 2,
        isLiked: false,
        birdId: 2,
        birdName: "참새",
        user: Local.UserSummary(
            id: 11,
            nickname: "새록초보",
            profileImageUrl: "https://cdn.example.com/user-profile-images/11.jpg"
        ),
        suggestionUserCount: nil
    )

    static let mock3: Local.CommunityItemSummary = .init(
        id: 3,
        imageURL: nil,
        discoveredDate: Date(timeIntervalSince1970: 1_710_000_000),
        latitude: 35.1796,
        longitude: 129.0756,
        locationAlias: "부산 해운대",
        address: "부산광역시 해운대구",
        note: "갈매기가 파도 위를 스치듯 날아다녔어요",
        likeCount: 32,
        commentCount: 12,
        isLiked: true,
        birdId: 3,
        birdName: "갈매기",
        user: Local.UserSummary(
            id: 12,
            nickname: "바다새연구가",
            profileImageUrl: "https://cdn.example.com/user-profile-images/12.jpg"
        ),
        suggestionUserCount: nil
    )

    static let mocks: [Local.CommunityItemSummary] = [mock1, mock2, mock3]

    // Pending mock items (has suggestionUserCount)
    static let pendingMock1: Local.CommunityItemSummary = .init(
        id: 101,
        imageURL: "https://cdn.example.com/collection-images/101.jpg",
        discoveredDate: Date(timeIntervalSince1970: 1_700_500_000),
        latitude: 37.401,
        longitude: 127.108,
        locationAlias: "판교",
        address: "경기도 성남시 분당구",
        note: "정확한 종 식별이 필요해요",
        likeCount: 3,
        commentCount: 1,
        isLiked: false,
        birdId: nil,
        birdName: nil,
        user: Local.UserSummary(
            id: 20,
            nickname: "식별요청자",
            profileImageUrl: "https://cdn.example.com/user-profile-images/20.jpg"
        ),
        suggestionUserCount: 2
    )

    static let pendingMock2: Local.CommunityItemSummary = .init(
        id: 102,
        imageURL: "https://cdn.example.com/collection-images/102.jpg",
        discoveredDate: Date(timeIntervalSince1970: 1_706_000_000),
        latitude: 37.5796,
        longitude: 126.9770,
        locationAlias: "경복궁",
        address: "서울특별시 종로구",
        note: "사진이 흔들려서 구분이 어려워요",
        likeCount: 5,
        commentCount: 0,
        isLiked: false,
        birdId: nil,
        birdName: nil,
        user: Local.UserSummary(
            id: 21,
            nickname: "사진러",
            profileImageUrl: "https://cdn.example.com/user-profile-images/21.jpg"
        ),
        suggestionUserCount: 0
    )

    static let pendingMock3: Local.CommunityItemSummary = .init(
        id: 103,
        imageURL: nil,
        discoveredDate: Date(timeIntervalSince1970: 1_711_000_000),
        latitude: 33.4996,
        longitude: 126.5312,
        locationAlias: "제주 구좌",
        address: "제주특별자치도 제주시",
        note: "해안가 풀숲에서 관찰",
        likeCount: 21,
        commentCount: 6,
        isLiked: true,
        birdId: nil,
        birdName: nil,
        user: Local.UserSummary(
            id: 22,
            nickname: "제주탐조가",
            profileImageUrl: "https://cdn.example.com/user-profile-images/22.jpg"
        ),
        suggestionUserCount: 12
    )

    static let pendingMocks: [Local.CommunityItemSummary] = [pendingMock1, pendingMock2, pendingMock3]
}
