//
//  Bird.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Foundation
import SwiftData

extension Local {
    @Model
    final class Bird {
        @Attribute(.unique) var id: Int64
        var name: String              // 국명
        var scientificName: String    // 학명
        var detail: String            // 세부 내용 (생김새, 분포 등)
        var classification: String    // 생물학적 분류
        var seasons: [Season]         // 계절
        var habitats: [Habitat]       // 서식지
        var size: BirdSize            // 크기 (열거형)
        var imageURL: String?         // 이미지 URL
        var isBookmarked: Bool        // 북마크 여부
        
        // MARK: #Predicate 지원
        
        var seasonRaw: String
        var habitatRaw: String
        var sizeRaw: String
        
        init(
            id: Int64,
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
            self.id = id
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
            self.sizeRaw = size.rawValue
        }
    }
}

extension Local.Bird {
    static func from(dto: DTO.Bird) -> Local.Bird? {
        let imageURL = dto.images.first(where: { $0.isThumb })?.s3Url
        
        let seasons = dto.seasonsWithRarity.compactMap { Season(serverRawValue: $0.season) }
        let habitats = dto.habitats.compactMap { Habitat(serverRawValue: $0) }

        let size = BirdSize.fromLength(dto.bodyLengthCm)
        
        let classification = [
            dto.taxonomy.classKor,
            dto.taxonomy.orderKor,
            dto.taxonomy.familyKor
        ].joined(separator: " > ")

        return Local.Bird(
            id: dto.id,
            name: dto.name.koreanName,
            scientificName: dto.name.scientificName,
            detail: dto.description.description,
            classification: classification,
            seasons: seasons,
            habitats: habitats,
            size: size,
            imageURL: imageURL
        )
    }
}

extension Array where Element == DTO.Bird {
    func toLocalBirds() -> [Local.Bird] {
        self.compactMap { Local.Bird.from(dto: $0) }
    }
}

// MARK: - Mock Data

extension Local.Bird {
    static let mockData: [Local.Bird] = [
        .init(
            id: 901,
            name: "가짜청딱따구리",
            scientificName: "Picus canus",
            detail: "청딱따구리는 길이가 25~26cm로 딱따구리 중에서 큰 편에 속하는 새이고, 날개 폭이 38~40cm이며, 무게는 약 125g이다.  청딱따구리는 윗부분이 올리브 녹색으로 균일하고 목을 가로질러 밝은 회색으로 변하며 머리는 후자의 색이다. 전형적인 딱따구리 표시는 작고 특별히 눈에 띄지 않는다. 회색 머리에 검은 콧수염이 있고, 수컷은 붉은 왕관을 갖고 있다. ",
            classification: "딱따구리목 > 딱따구리과 > 딱따구리속",
            seasons: [.spring, .summer],
            habitats: [.wetland],
            size: .hummingbird,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/%D0%A1%D0%B5%D0%B4%D0%BE%D0%B9_%D0%B4%D1%8F%D1%82%D0%B5%D0%BB_%D1%83_%D0%B1%D0%BE%D0%BB%D0%BE%D1%82%D0%B0_%D1%80%D0%B5%D1%87%D0%BA%D0%B8_%D0%97%D0%B8%D0%BC%D1%91%D0%BD%D0%BA%D0%B8.jpg/960px-%D0%A1%D0%B5%D0%B4%D0%BE%D0%B9_%D0%B4%D1%8F%D1%82%D0%B5%D0%BB_%D1%83_%D0%B1%D0%BE%D0%BB%D0%BE%D1%82%D0%B0_%D1%80%D0%B5%D1%87%D0%BA%D0%B8_%D0%97%D0%B8%D0%BC%D1%91%D0%BD%D0%BA%D0%B8.jpg"
        ),
        .init(
            id: 902,
            name: "가짜참새",
            scientificName: "Passer domesticus",
            detail: "참새는 흔히 볼 수 있는 소형 조류로, 도시와 시골 어디서나 볼 수 있다. 몸길이는 약 14~16cm이며 갈색과 회색이 섞인 깃털을 가지고 있다.",
            classification: "참새목 > 참새과 > 참새속",
            seasons: [.spring, .summer, .autumn, .winter],
            habitats: [.forest, .urban],
            size: .hummingbird,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Tree_Sparrow_August_2007_Osaka_Japan.jpg/960px-Tree_Sparrow_August_2007_Osaka_Japan.jpg"
        ),

        .init(
            id: 903,
            name: "가짜참매",
            scientificName: "Accipiter gentilis",
            detail: "참매는 중형猛禽류로 강력한 날개와 꼬리를 이용해 숲 속을 빠르게 비행하며 사냥을 한다. 몸길이는 약 55cm, 날개 폭은 약 105~115cm에 달한다.",
            classification: "매목 > 매과 > 참매속",
            seasons: [.spring, .autumn, .winter],
            habitats: [.forest],
            size: .pigeon,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Northern_Goshawk_ad_M2.jpg/600px-Northern_Goshawk_ad_M2.jpg"
        ),

        .init(
            id: 904,
            name: "가짜물총새",
            scientificName: "Alcedo atthis",
            detail: "작고 색이 화려한 새로, 몸길이는 약 16~17cm이다. 물고기를 잡아먹으며, 강가나 호숫가에서 자주 관찰된다. 푸른 등과 주황색 배가 특징이다.",
            classification: "파랑새목 > 물총새과 > 물총새속",
            seasons: [.spring, .summer, .autumn],
            habitats: [.wetland],
            size: .hummingbird,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706155335721_0XCGKN3XR.jpg/ia82_132_i2.jpg?type=m1500"
        ),

        .init(
            id: 905,
            name: "가짜쇠백로",
            scientificName: "Egretta garzetta",
            detail: "길고 가는 목과 다리를 가진 흰색의 우아한 새로, 물가나 습지에서 자주 관찰된다. 몸길이는 약 55~65cm에 달한다.",
            classification: "황새목 > 백로과 > 백로속",
            seasons: [.spring, .summer],
            habitats: [.wetland],
            size: .eagle,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Egretta_garzetta_-_Little_egret_01.jpg/960px-Egretta_garzetta_-_Little_egret_01.jpg"
        ),

        .init(
            id: 906,
            name: "가짜황조롱이",
            scientificName: "Falco tinnunculus",
            detail: "소형 맹금류로, 개활지에서 자주 사냥을 한다. 특유의 정지비행으로 잘 알려져 있다. 몸길이는 약 35cm, 날개 폭은 약 70~80cm.",
            classification: "매목 > 매과 > 매속",
            seasons: [.spring, .autumn],
            habitats: [.forest],
            size: .pigeon,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Common_kestrel_falco_tinnunculus.jpg/960px-Common_kestrel_falco_tinnunculus.jpg"
        ),
        .init(
            id: 907,
            name: "가짜방울새",
            scientificName: "Chloris sinica",
            detail: "우리나라 전역에서 관찰이 가능한 흔한 텃새이다. 중국, 만주, 일본 등 동부아시아에서 서식한다. 아종에는 제주도에서만 번식하는 장박새와 울도방울새가 있다. 학명은 Carduelis sinica ussuriensis인데, ‘엉겅퀴를 좋아한다’라는 뜻이다. 영문 이름인 Oriental Greenfinch는 ‘동아시아에서 서식하는 종자를 즐겨 먹는 푸른빛을 띤 새’라는 뜻이다.\n\n날개 길이는 79∼83.5㎜, 부리 길이는 10∼11㎜, 부척(跗蹠: 새의 다리에서 정강이뼈와 발가락 사이의 부분)은 15∼16㎜이다. 머리는 회갈색이며 윗면과 아랫면은 갈색이다. 번식기는 4∼8월이며 2차 번식도 한다. 번식 장소는 인가 부근 혹은 공원 등지이며 둥지는 이끼류, 마른풀, 식물 뿌리 등으로 만든다. \n\n한배 산란 수는 2∼5개이고 포란 기간은 12일이다. 어미새는 먹이를 소낭에 저장하여 새끼에게 토해서 먹이를 준다. 겨울철 먹이는 주로 식물성인데, 잡초씨와 조·벼·밀·수수 등의 곡류가 대부분이다. 번식 기간인 여름철엔 대부분 곤충류를 먹는다. 번식기 외에는 대부분 20∼30개체의 무리로 이동한다. 방울새라는 국명은 울음소리가 ‘또르르륵, 또르르륵’하는 작은 방울소리가 난다고 해서 붙여졌다. 김영일(金英一) 작사, 김성태(金聖泰) 작곡의 ‘방울새’라는 동요가 있는데 방울새의 방울소리를 재미있게 표현하였다. \n\n방울새야 방울새야 쪼로롱 방울새야/ 간밤에 고방을 어디서 사왔니/ 쪼로롱 고방을 어디서 사왔니/ 방울새야 방울새야 쪼로롱 방울새야/ 너 갈 제 고 방울 나 주고 가렴/ 쪼로롱 고방울 나 주고 가렴.",
            classification: "매목 > 매과 > 매속",
            seasons: [.spring, .autumn],
            habitats: [.forest],
            size: .hummingbird,
            imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706160452691_JI99WEUYC.jpg/ia82_148_i1.jpg?type=m1500"
        ),
        .init(
                id: 908,
                name: "가짜오목눈이",
                scientificName: "Aegithalos caudatus",
                detail: "오목눈이는 작은 몸집과 둥글둥글한 외모로 사랑받는 새입니다. 부리는 짧고 눈이 커서 귀여운 인상을 줍니다. 나뭇가지에 매달리거나 재빠르게 이동하는 모습을 볼 수 있습니다.",
                classification: "참새목 > 오목눈이과 > 오목눈이속",
                seasons: [.spring, .autumn, .winter],
                habitats: [.forest],
                size: .hummingbird,
                imageURL: "https://dbscthumb-phinf.pstatic.net/2765_000_32/20241114060540131_LT2LRTVXY.jpg/13029503.jpg?type=m1500"
            ),
        .init(
                id: 909,
                name: "가짜긴꼬리딱새",
                scientificName: "Terpsiphone atrocaudata",
                detail: "긴꼬리딱새는 여름철에 매우 드물게 번식하는 희귀 여름철새입니다. 수컷은 길고 아름다운 꼬리깃을 가지고 있으며, 숲 속 그늘진 곳을 좋아합니다.",
                classification: "참새목 > 딱새과 > 긴꼬리딱새속",
                seasons: [.summer],
                habitats: [.forest],
                size: .hummingbird,
                imageURL: "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyNDA2MDNfNTYg%2FMDAxNzE3Mzc1Njk2MzM1.FBuebOCbKQ4URHUDBhcAOW9v9W9u1z0qnS5ljwTfLbog.YlfRFXym1eqpVpSMWqoXJJ-TZ0b4k46YK7spWfY-bbkg.JPEG%2FJKPT8352.JPG&type=sc960_832"
            ),
            .init(
                id: 910,
                name: "가짜양비둘기",
                scientificName: "Columba eversmanni",
                detail: "양비둘기는 광활한 초원을 선호하는 비둘기로, 우리나라에서는 극히 드물게 관찰됩니다. 몸집이 크고, 비교적 무거운 체형을 가지고 있습니다.",
                classification: "비둘기목 > 비둘기과 > 비둘기속",
                seasons: [.winter],
                habitats: [.farmland],
                size: .pigeon,
                imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706171345642_G2N6DRCS9.jpg/ia82_234_i3.jpg?type=m1500"
            ),
            .init(
                id: 911,
                name: "가짜흰물떼새",
                scientificName: "Charadrius alexandrinus",
                detail: "흰물떼새는 드물게 우리나라 해안가에서 번식하는 종입니다. 흰색과 연한 갈색을 띠며, 조심스럽게 모래사장에서 이동하는 모습이 특징입니다.",
                classification: "도요목 > 물떼새과 > 물떼새속",
                seasons: [.spring, .summer],
                habitats: [.wetland],
                size: .hummingbird,
                imageURL: "https://dbscthumb-phinf.pstatic.net/3997_000_1/20150706185010184_HJI9F0WND.jpg/ia82_354_i5.jpg?type=m1500"
            )
    ]
}
