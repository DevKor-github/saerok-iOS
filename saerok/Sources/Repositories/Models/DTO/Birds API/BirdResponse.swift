//
//  BirdsResponse.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//


import Foundation

enum DTO { }

extension DTO {
    struct BirdsResponse: Codable {
        let birds: [DTO.Bird]
    }
    
    struct Bird: Codable, Identifiable {
        struct Name: Codable {
            let koreanName: String
            let scientificName: String
            let scientificAuthor: String
            let scientificYear: Int
        }

        struct Taxonomy: Codable {
            let phylumEng: String
            let phylumKor: String
            let classEng: String
            let classKor: String
            let orderEng: String
            let orderKor: String
            let familyEng: String
            let familyKor: String
            let genusEng: String
            let genusKor: String
            let speciesEng: String
            let speciesKor: String
        }

        struct Description: Codable {
            let description: String
            let source: String
            let isAiGenerated: Bool
        }

        struct SeasonRarity: Codable {
            let season: String
            let rarity: String
            let priority: Int
        }

        struct Image: Codable {
            let isThumb: Bool
            let s3Url: String
            let originalUrl: String
            let orderIndex: Int
        }

        let id: Int
        let name: Name
        let taxonomy: Taxonomy
        let description: Description
        let bodyLengthCm: Double
        let nibrUrl: String
        let habitats: [String]
        let seasonsWithRarity: [SeasonRarity]
        let images: [Image]
        let updatedAt: String
    }
}
