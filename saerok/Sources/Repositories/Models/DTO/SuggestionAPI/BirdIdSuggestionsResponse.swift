//
//  BirdIdSuggestionsResponse.swift
//  saerok
//
//  Created by HanSeung on 7/31/25.
//


extension DTO {
    struct BirdIdSuggestionsResponse: Decodable {
        let items: [BirdIdSuggestion]
        
        struct BirdIdSuggestion: Decodable {
            let birdId: Int
            let birdKoreanName: String
            let birdScientificName: String
            let birdImageUrl: String
            let agreeCount: Int
            let isAgreedByMe: Bool
        }
    }
}

extension DTO {
    struct SuggestBirdIdResponse: Decodable {
        let suggestionId: Int
    }
}

extension DTO {
    struct AdoptBirdSuggestionResponse: Decodable {
        let collectionId: Int
        let birdId: Int
        let birdKoreanName: String
    }
}
