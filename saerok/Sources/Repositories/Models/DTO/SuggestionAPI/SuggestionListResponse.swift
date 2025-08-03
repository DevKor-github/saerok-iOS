//
//  BirdIdSuggestionsResponse.swift
//  saerok
//
//  Created by HanSeung on 7/31/25.
//


extension DTO {
    struct SuggestionListResponse: Decodable {
        let items: [BirdIdSuggestion]
        
        struct BirdIdSuggestion: Decodable {
            let birdId: Int
            let birdKoreanName: String
            let birdScientificName: String
            let birdImageUrl: String
            let agreeCount: Int
            let disagreeCount: Int
            let isAgreedByMe: Bool
            let isDisagreedByMe: Bool
        }
    }
}

extension DTO {
    struct SuggestResponse: Decodable {
        let suggestionId: Int
    }
    
    struct AdoptSuggestionResponse: Decodable {
        let collectionId: Int
        let birdId: Int
        let birdKoreanName: String
    }
    
    struct ToggleSuggestionResponse: Decodable {
        let agreeCount: Int
        let disagreeCount: Int
        let isAgreedByMe: Bool
        let isDisagreedByMe: Bool
    }
}
