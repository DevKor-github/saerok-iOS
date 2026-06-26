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
    final class Bird: Equatable, Sendable {
        @Attribute(.unique) var id: Int
        var name: String              // 국명
        var scientificName: String    // 학명
        var detail: String            // 세부 내용 (생김새, 분포 등)
        var classification: String    // 생물학적 분류
        var seasons: [Season]         // 계절
        var habitats: [Habitat]       // 서식지
        var size: BirdSize            // 크기 (열거형)
        var imageURL: String?         // 이미지 URL
        var isBookmarked: Bool        // 북마크 여부
        var isProtected: Bool = false // 보호종 여부 (보호등급이 NONE이 아니면 true)

        // MARK: #Predicate 지원
        var seasonRaw: String
        var habitatRaw: String
        var sizeRaw: String
        
        init(
            id: Int,
            name: String,
            scientificName: String,
            detail: String,
            classification: String,
            seasons: [Season],
            habitats: [Habitat],
            size: BirdSize,
            imageURL: String? = nil,
            isBookmarked: Bool = false,
            isProtected: Bool = false
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
            self.isProtected = isProtected
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
            imageURL: imageURL,
            isProtected: (dto.conservationGrade ?? "NONE") != "NONE"
        )
    }
}

extension Array where Element == DTO.Bird {
    func toLocalBirds() -> [Local.Bird] {
        self.compactMap { Local.Bird.from(dto: $0) }
    }
}

extension Local.Bird {
    static let mockData: Local.Bird = .init(id: 0, name: "이름 모를 새", scientificName: "", detail: "", classification: "", seasons: [], habitats: [], size: .duck)
}
