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
}

enum Habitat: String, Codable, CaseIterable, Equatable {
    case forest = "산"
    case wetland = "하천/호수"
    case urban = "도시"
    case coastal = "해안"
    case farmland = "농경"
}

enum BirdSize: String, Codable, CaseIterable, Equatable {
    case hummingbird = "벌새"
    case pigeon = "비둘기"
    case eagle = "독수리"
}
