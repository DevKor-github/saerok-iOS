//
//  Bird.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation
import SwiftData

enum Season: String, Codable, CaseIterable {
    case spring = "봄"
    case summer = "여름"
    case autumn = "가을"
    case winter = "겨울"
}

enum Habitat: String, Codable, CaseIterable {
    case forest = "산"
    case wetland = "하천/호수"
    case urban = "도시"
    case coastal = "해안"
    case farmland = "농경"
}

enum BirdSize: String, Codable, CaseIterable {
    case hummingbird = "벌새 크기"
    case pigeon = "비둘기 크기"
    case eagle = "독수리 크기"
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
            name: "청딱따구리",
            scientificName: "Picus canus",
            detail: "청딱따구리는 길이가 25~26cm로 딱따구리 중에서 큰 편에 속하는 새이고, 날개 폭이 38~40cm이며, 무게는 약 125g이다.  청딱따구리는 윗부분이 올리브 녹색으로 균일하고 목을 가로질러 밝은 회색으로 변하며 머리는 후자의 색이다. 전형적인 딱따구리 표시는 작고 특별히 눈에 띄지 않는다. 회색 머리에 검은 콧수염이 있고, 수컷은 붉은 왕관을 갖고 있다. ",
            classification: "딱따구리목 > 딱따구리과 > 딱따구리속",
            seasons: [.spring, .summer],
            habitats: [.wetland],
            size: .hummingbird
        ),
        .init(
            name: "참새",
            scientificName: "Passer montanus",
            detail: "참새는 길이가 25~26cm로 딱따구리 중에서 큰 편에 속하는 새이고, 날개 폭이 38~40cm이며, 무게는 약 125g이다.  청딱따구리는 윗부분이 올리브 녹색으로 균일하고 목을 가로질러 밝은 회색으로 변하며 머리는 후자의 색이다. 전형적인 딱따구리 표시는 작고 특별히 눈에 띄지 않는다. 회색 머리에 검은 콧수염이 있고, 수컷은 붉은 왕관을 갖고 있다. ",
            classification: "조류 > 참새목 > 참새과",
            seasons: [.spring, .summer, .autumn, .winter],
            habitats: [.urban, .farmland],
            size: .hummingbird
        ),
        .init(
            name: "붉은배지느러미발도요",
            scientificName: "Phalaropus fulicarius",
            detail: "작고 흔하게 볼 수 있는 새로, 도시와 농촌 어디에서나 관찰 가능하다.",
            classification: "조류 > 참새목 > 참새과",
            seasons: [.spring, .summer, .autumn, .winter],
            habitats: [.urban, .farmland],
            size: .hummingbird
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
