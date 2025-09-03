//
//  NearbyCollectionItem.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//


extension Local {
    struct NearbyCollectionSummary: Decodable, Equatable {
        let collectionId: Int
        let imageUrl: String?
        let koreanName: String?
        let latitude: Double
        let longitude: Double
        let note: String
        let locationAlias: String
        let likeCount: Int
        let commentCount: Int
        let isLiked: Bool
        let user: User
    }
    
    struct User: Codable, Equatable {
        let userId: Int
        let nickname: String
        let profileImageUrl: String
    }
}

extension Local.NearbyCollectionSummary {
    static func from(dto: DTO.NearbyCollectionItem) -> Local.NearbyCollectionSummary {
        .init(collectionId: dto.collectionId,
              imageUrl: dto.imageUrl,
              koreanName: dto.koreanName,
              latitude: dto.latitude,
              longitude: dto.longitude,
              note: dto.note,
              locationAlias: dto.locationAlias,
              likeCount: dto.likeCount,
              commentCount: dto.commentCount,
              isLiked: dto.isLiked,
              user: .init(
                userId: dto.user.userId,
                nickname: dto.user.nickname,
                profileImageUrl: dto.user.profileImageUrl
              )
        )
    }
}

extension Local.NearbyCollectionSummary {
    static let mockData: [Local.NearbyCollectionSummary] = [
        .init(
            collectionId: 1,
            imageUrl: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706145130176_A6K6GWVX2.jpg/ia82_60_i4.jpg?type=m1500",
            koreanName: "까치",
            latitude: 37.987654,
            longitude: 127.123456,
            note: "광화문에서 까치가 날아다녔어요, 광화문에서 까치가 걸어당겼어요, 광화문에서 까치가 누워있었어요",
            locationAlias: "서울숲",
            likeCount: 15,
            commentCount: 7,
            isLiked: true,
            user: .init(
                userId: 10,
                nickname: "안암동새록마스터",
                profileImageUrl: "https://dbscthumb-phinf.pstatic.net/3150_000_1/20140625111001453_961TT2ILF.jpg/a_332_1.jpg?type=m1500"
            )
        ),
        .init(
            collectionId: 2,
            imageUrl: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706174655287_5CQ0PFVKS.jpg/ia82_273_i1.jpg?type=m1500",
            koreanName: "참새",
            latitude: 37.123456,
            longitude: 127.654321,
            note: "한강변에서 참새가 지저귀네요",
            locationAlias: "한강공원",
            likeCount: 8,
            commentCount: 3,
            isLiked: false,
            user: .init(
                userId: 20,
                nickname: "새싹탐험가",
                profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fshop1.phinf.naver.net%2F20200714_123%2F1594709026614GDY7h_JPEG%2F32071360207595716_644854938.jpg&type=sc960_832"
            )
        )
    ]
}
