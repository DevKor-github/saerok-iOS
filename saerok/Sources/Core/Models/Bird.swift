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
