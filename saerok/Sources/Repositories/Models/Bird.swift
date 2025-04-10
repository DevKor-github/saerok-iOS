//
//  Bird.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation
import SwiftData

enum Season: String, Codable, CaseIterable {
    case spring
    case summer
    case autumn
    case winter
}

enum Habitat: String, Codable, CaseIterable {
    case forest
    case wetland
    case urban
    case coastal
    case farmland
}

enum BirdSize: String, Codable, CaseIterable {
    case sparrow
    case pigeon
    case eagle
}

extension Local {
    @Model
    final class Bird {
        var name: String              // 국명
        var scientificName: String    // 학명
        var detail: String            // 세부 내용 (생김새, 분포 등)
        var classification: String    // 생물학적 분류
        var seasons: [Season]         // 계절
        var habitats: [Habitat]       // 서식지
        var size: BirdSize            // 크기 (열거형)
        var imageURL: URL?            // 이미지 URL
        var isBookmarked: Bool        // 북마크 여부
        
        init(
            name: String,
            scientificName: String,
            detail: String,
            classification: String,
            seasons: [Season],
            habitats: [Habitat],
            size: BirdSize,
            imageURL: URL? = nil,
            isBookmarked: Bool = false
        ) {
            self.name = name
            self.scientificName = scientificName
            self.detail = detail
            self.classification = classification
            self.seasons = seasons
            self.habitats = habitats
            self.size = size
            self.imageURL = imageURL
            self.isBookmarked = isBookmarked
        }
    }
}


// MARK: - Mock Data

extension Local.Bird {
    static let mockData: [Local.Bird] = [
        .init(
            name: "참새",
            scientificName: "Passer montanus",
            detail: "작고 흔하게 볼 수 있는 새로, 도시와 농촌 어디에서나 관찰 가능하다.",
            classification: "조류 > 참새목 > 참새과",
            seasons: [.spring, .summer, .autumn, .winter],
            habitats: [.urban, .farmland],
            size: .sparrow
        ),
        .init(
            name: "붉은배지느러미발도요",
            scientificName: "Phalaropus fulicarius",
            detail: "작고 흔하게 볼 수 있는 새로, 도시와 농촌 어디에서나 관찰 가능하다.",
            classification: "조류 > 참새목 > 참새과",
            seasons: [.spring, .summer, .autumn, .winter],
            habitats: [.urban, .farmland],
            size: .sparrow
        ),
        .init(
            name: "까치",
            scientificName: "Pica pica",
            detail: "흑백의 깃털이 특징이며, 지능이 높은 새로 알려져 있다.",
            classification: "조류 > 참새목 > 까마귀과",
            seasons: [.spring, .summer, .autumn],
            habitats: [.urban, .forest],
            size: .pigeon
        ),
        .init(
            name: "왜가리",
            scientificName: "Ardea cinerea",
            detail: "긴 다리와 목을 가진 물가의 새로, 고요한 하천에서 자주 볼 수 있다.",
            classification: "조류 > 황새목 > 왜가리과",
            seasons: [.spring, .summer],
            habitats: [.wetland],
            size: .eagle
        ),
        .init(
            name: "독수리",
            scientificName: "Aquila chrysaetos",
            detail: "산악 지대에서 서식하며 먹이를 사냥하는 맹금류이다.",
            classification: "조류 > 매목 > 수리과",
            seasons: [.autumn, .winter],
            habitats: [.forest, .coastal],
            size: .eagle
        ),
        .init(
            name: "물닭",
            scientificName: "Fulica atra",
            detail: "검은 깃털과 흰 부리가 특징이며, 연못이나 하천에서 쉽게 볼 수 있다.",
            classification: "조류 > 두루미목 > 뜸부기과",
            seasons: [.spring, .summer],
            habitats: [.wetland, .farmland],
            size: .pigeon
        ),
        .init(
            name: "물닭",
            scientificName: "Fulica atra",
            detail: "검은 깃털과 흰 부리가 특징이며, 연못이나 하천에서 쉽게 볼 수 있다.",
            classification: "조류 > 두루미목 > 뜸부기과",
            seasons: [.spring, .summer],
            habitats: [.wetland, .farmland],
            size: .pigeon
        ),
        .init(
            name: "물닭",
            scientificName: "Fulica atra",
            detail: "검은 깃털과 흰 부리가 특징이며, 연못이나 하천에서 쉽게 볼 수 있다.",
            classification: "조류 > 두루미목 > 뜸부기과",
            seasons: [.spring, .summer],
            habitats: [.wetland, .farmland],
            size: .pigeon
        ),
        .init(
            name: "물닭",
            scientificName: "Fulica atra",
            detail: "검은 깃털과 흰 부리가 특징이며, 연못이나 하천에서 쉽게 볼 수 있다.",
            classification: "조류 > 두루미목 > 뜸부기과",
            seasons: [.spring, .summer],
            habitats: [.wetland, .farmland],
            size: .pigeon
        )
    ]
}
