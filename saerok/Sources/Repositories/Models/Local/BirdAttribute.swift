//
//  BirdAttribute.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//

import SwiftUICore

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
    case mudflat = "갯벌"
    case farmland = "농경지"
    case forest = "산림"
    case coastal = "해양"
    case residential = "주거지"
    case plainsForest = "평지/숲"
    case riverLake = "하천/호수"
    case artificial = "인공시설"
    case cave = "동굴"
    case wetland = "습지"
    case urban = "도시"
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
    case sparrow = "참새"
    case pigeon = "비둘기"
    case duck = "오리"
    case kayak = "기러기"
}

extension BirdSize {
    static func fromLength(_ length: Double) -> BirdSize {
        switch length {
        case ..<15: return .sparrow
        case 15..<30: return .pigeon
        case 30..<54: return .duck
        case 54... : return .kayak
        default: return .sparrow
        }
    }
    
    var lengthDescription: String {
        switch self {
        case .sparrow: "~15cm"
        case .pigeon: "~30cm"
        case .duck: "~54cm"
        case .kayak: "54cm 이상"
        }
    }
    
    var image: Image {
        switch self {
        case .sparrow: .init(.birdFilter1)
        case .pigeon: .init(.birdFilter2)
        case .duck: .init(.birdFilter3)
        case .kayak: .init(.birdFilter4)
        }
    }
}
