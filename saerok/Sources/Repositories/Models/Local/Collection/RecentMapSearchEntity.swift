//
//  RecentMapSearchEntity.swift
//  saerok
//
//  Created by HanSeung on 7/14/26.
//


import Foundation
import SwiftData

extension Local {
    /// 지도 검색 기록의 종류.
    /// 종류를 추가할 때는 case → RecentMapSearchEntity의 편의 init → 셀 아이콘 매핑 세 지점만 확장한다.
    enum MapSearchKind: String, Codable {
        case place
        case bird
    }

    /// 지도 검색 기록. 위치·새(추후) 기록을 하나의 모델에 `kind`로 담아 통합 최신순으로 다룬다.
    /// 종류별 데이터는 optional 슬롯으로 두고, `kind`로 렌더링·내비게이션을 분기한다.
    @Model
    final class RecentMapSearchEntity {
        /// 도메인 식별자. 상위 계층(Interactor·ViewModel·View)이 SwiftData의
        /// `PersistentIdentifier`를 알지 않도록 UUID를 식별·삭제 키로 쓴다.
        var uuid: UUID
        var kindRaw: String
        var keyword: String
        var createdAt: Date

        // MARK: place 전용 슬롯
        var placeAddress: String?
        var latitude: Double?
        var longitude: Double?

        // MARK: bird 전용 슬롯
        var birdId: Int?

        var kind: MapSearchKind { MapSearchKind(rawValue: kindRaw) ?? .place }

        init(
            kindRaw: String,
            keyword: String,
            createdAt: Date = .now,
            placeAddress: String? = nil,
            latitude: Double? = nil,
            longitude: Double? = nil,
            birdId: Int? = nil
        ) {
            self.uuid = UUID()
            self.kindRaw = kindRaw
            self.keyword = keyword
            self.createdAt = createdAt
            self.placeAddress = placeAddress
            self.latitude = latitude
            self.longitude = longitude
            self.birdId = birdId
        }

        convenience init(place: Local.KakaoPlace, createdAt: Date = .now) {
            self.init(
                kindRaw: MapSearchKind.place.rawValue,
                keyword: place.placeName,
                createdAt: createdAt,
                placeAddress: place.address.isEmpty ? place.roadAddress : place.address,
                latitude: place.latitude,
                longitude: place.longitude
            )
        }

        // 추후: convenience init(bird: Local.Bird, createdAt: Date = .now) { ... kindRaw = .bird ... }
    }

    /// 지도 검색 기록의 값 타입 스냅샷.
    /// `@Model`은 컨텍스트에 묶여 있고 Sendable이 아니므로, View/ViewModel에는 이 값 타입만 전달한다.
    /// 식별·삭제 키는 도메인 UUID — SwiftData 지식이 Repository 위로 새지 않는다.
    struct RecentMapSearch: Identifiable, Equatable {
        let id: UUID
        let kind: MapSearchKind
        let keyword: String
        let createdAt: Date
        let latitude: Double?
        let longitude: Double?
        let birdId: Int?
    }
}

extension Local.RecentMapSearchEntity {
    /// 엔티티 → 값 타입 스냅샷 변환.
    var snapshot: Local.RecentMapSearch {
        .init(
            id: uuid,
            kind: kind,
            keyword: keyword,
            createdAt: createdAt,
            latitude: latitude,
            longitude: longitude,
            birdId: birdId
        )
    }
}
