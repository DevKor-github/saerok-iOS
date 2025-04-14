//
//  Bird.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation
import SwiftData

enum Season: String, Codable, CaseIterable, Equatable {
    case spring = "봄"
    case summer = "여름"
    case autumn = "가을"
    case winter = "겨울"
}

enum Habitat: String, Codable, CaseIterable, Equatable {
    case forest = "산"
    case wetland = "하천/호수"
    case urban = "도시"
    case coastal = "해안"
    case farmland = "농경"
}

enum BirdSize: String, Codable, CaseIterable, Equatable {
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
        var imageURL: String?         // 이미지 URL
        var isBookmarked: Bool        // 북마크 여부
        
        var seasonRaw: String
        var habitatRaw: String
        
        init(
            name: String,
            scientificName: String,
            detail: String,
            classification: String,
            seasons: [Season],
            habitats: [Habitat],
            size: BirdSize,
            imageURL: String? = nil,
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
            self.seasonRaw = seasons.map { $0.rawValue }.joined()
            self.habitatRaw = habitats.map { $0.rawValue }.joined()
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
            size: .hummingbird,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/%D0%A1%D0%B5%D0%B4%D0%BE%D0%B9_%D0%B4%D1%8F%D1%82%D0%B5%D0%BB_%D1%83_%D0%B1%D0%BE%D0%BB%D0%BE%D1%82%D0%B0_%D1%80%D0%B5%D1%87%D0%BA%D0%B8_%D0%97%D0%B8%D0%BC%D1%91%D0%BD%D0%BA%D0%B8.jpg/960px-%D0%A1%D0%B5%D0%B4%D0%BE%D0%B9_%D0%B4%D1%8F%D1%82%D0%B5%D0%BB_%D1%83_%D0%B1%D0%BE%D0%BB%D0%BE%D1%82%D0%B0_%D1%80%D0%B5%D1%87%D0%BA%D0%B8_%D0%97%D0%B8%D0%BC%D1%91%D0%BD%D0%BA%D0%B8.jpg"
        ),
        .init(
            name: "참새",
            scientificName: "Passer domesticus",
            detail: "참새는 흔히 볼 수 있는 소형 조류로, 도시와 시골 어디서나 볼 수 있다. 몸길이는 약 14~16cm이며 갈색과 회색이 섞인 깃털을 가지고 있다.",
            classification: "참새목 > 참새과 > 참새속",
            seasons: [.spring, .summer, .autumn, .winter],
            habitats: [.forest, .urban],
            size: .hummingbird,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Tree_Sparrow_August_2007_Osaka_Japan.jpg/960px-Tree_Sparrow_August_2007_Osaka_Japan.jpg"
        ),

        .init(
            name: "참매",
            scientificName: "Accipiter gentilis",
            detail: "참매는 중형猛禽류로 강력한 날개와 꼬리를 이용해 숲 속을 빠르게 비행하며 사냥을 한다. 몸길이는 약 55cm, 날개 폭은 약 105~115cm에 달한다.",
            classification: "매목 > 매과 > 참매속",
            seasons: [.spring, .autumn, .winter],
            habitats: [.forest],
            size: .pigeon,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Northern_Goshawk_ad_M2.jpg/600px-Northern_Goshawk_ad_M2.jpg"
        ),

        .init(
            name: "물총새",
            scientificName: "Alcedo atthis",
            detail: "작고 색이 화려한 새로, 몸길이는 약 16~17cm이다. 물고기를 잡아먹으며, 강가나 호숫가에서 자주 관찰된다. 푸른 등과 주황색 배가 특징이다.",
            classification: "파랑새목 > 물총새과 > 물총새속",
            seasons: [.spring, .summer, .autumn],
            habitats: [.wetland],
            size: .hummingbird,
            imageURL: "https://i.namu.wiki/i/qels_DGLZ7fXysLFYitKPXPDf2uqfmY9dFkIdH8y7ebc1ZW8KipArWDecRhsASQmKlhSV53uwT5-3_m2UyIwgD0Sx9-4kqrhVQ9ExUuO441AkGPXMZ0UTVrhQmsqXfaquybDDn41bhn__Op_qScyOw.webp"
        ),

        .init(
            name: "쇠백로",
            scientificName: "Egretta garzetta",
            detail: "길고 가는 목과 다리를 가진 흰색의 우아한 새로, 물가나 습지에서 자주 관찰된다. 몸길이는 약 55~65cm에 달한다.",
            classification: "황새목 > 백로과 > 백로속",
            seasons: [.spring, .summer],
            habitats: [.wetland],
            size: .eagle,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Egretta_garzetta_-_Little_egret_01.jpg/960px-Egretta_garzetta_-_Little_egret_01.jpg"
        ),

        .init(
            name: "황조롱이",
            scientificName: "Falco tinnunculus",
            detail: "소형 맹금류로, 개활지에서 자주 사냥을 한다. 특유의 정지비행으로 잘 알려져 있다. 몸길이는 약 35cm, 날개 폭은 약 70~80cm.",
            classification: "매목 > 매과 > 매속",
            seasons: [.spring, .autumn],
            habitats: [.forest],
            size: .pigeon,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Common_kestrel_falco_tinnunculus.jpg/960px-Common_kestrel_falco_tinnunculus.jpg"
        ),
    ]
}
