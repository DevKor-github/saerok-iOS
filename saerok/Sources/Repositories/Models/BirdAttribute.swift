//
//  BirdAttribute.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//

enum Season: String, Codable, CaseIterable, Equatable {
    case spring = "봄"
    case summer = "여름"
    case autumn = "가을"
    case winter = "겨울"

    init(serverRawValue: String) {
        switch serverRawValue {
        case "SPRING": self = .spring
        case "SUMMER": self = .summer
        case "AUTUMN", "FALL": self = .autumn
        case "WINTER": self = .winter
        default: self = .spring
        }
    }
}

enum Habitat: String, Codable, CaseIterable, Equatable {
    case forest = "산림"
    case wetland = "습지"
    case riverLake = "강/호수"
    case urban = "도시"
    case coastal = "해안"
    case farmland = "농경지"
    case mudflat = "갯벌"
    case artificial = "인공 구조물"
    case plainsForest = "초지/산림"
    case cave = "동굴"
    case residential = "주거지"
    case others = "기타"

    init(serverRawValue: String) {
        switch serverRawValue {
        case "FOREST": self = .forest
        case "WETLAND": self = .wetland
        case "RIVER_LAKE": self = .riverLake
        case "URBAN": self = .urban
        case "RESIDENTIAL": self = .residential
        case "COASTAL", "MARINE": self = .coastal
        case "MUDFLAT": self = .mudflat
        case "FARMLAND": self = .farmland
        case "ARTIFICIAL": self = .artificial
        case "PLAINS_FOREST": self = .plainsForest
        case "CAVE": self = .cave
        case "OTHERS": self = .others
        default: self = .others
        }
    }
}

enum BirdSize: String, Codable, CaseIterable, Equatable {
    case hummingbird = "벌새"
    case pigeon = "비둘기"
    case eagle = "독수리"
}

extension BirdSize {
    static func fromLength(_ length: Double) -> BirdSize {
        switch length {
        case ..<10: return .hummingbird
        case 10..<20: return .pigeon
        default: return .eagle
        }
    }
}
