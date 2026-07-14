//
//  RecentSearch.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import Foundation
import SwiftData

extension Local {
    @Model
    final class RecentSearchEntity {
        /// 도메인 식별자. 상위 계층(Interactor·ViewModel·View)이 SwiftData의
        /// `PersistentIdentifier`를 알지 않도록 UUID를 식별·삭제 키로 쓴다.
        var uuid: UUID
        @Relationship(deleteRule: .noAction) var bird: Local.Bird
        var createdAt: Date

        init(bird: Local.Bird, createdAt: Date = .now) {
            self.uuid = UUID()
            self.bird = bird
            self.createdAt = createdAt
        }
    }

    /// 도감 새 검색 기록의 값 타입 스냅샷.
    /// `@Model`은 컨텍스트에 묶여 있고 Sendable이 아니므로, View/ViewModel에는 이 값 타입만 전달한다.
    /// 셀 렌더에 필요한 이름·시각만 담고, 상세 이동은 `birdId`로 재조회한다.
    /// 식별·삭제 키는 도메인 UUID — SwiftData 지식이 Repository 위로 새지 않는다.
    struct RecentBirdSearch: Identifiable, Equatable {
        let id: UUID
        let birdId: Int
        let birdName: String
        let createdAt: Date
    }
}

extension Local.RecentSearchEntity {
    /// 엔티티 → 값 타입 스냅샷 변환.
    var snapshot: Local.RecentBirdSearch {
        .init(
            id: uuid,
            birdId: bird.id,
            birdName: bird.name,
            createdAt: createdAt
        )
    }
}
