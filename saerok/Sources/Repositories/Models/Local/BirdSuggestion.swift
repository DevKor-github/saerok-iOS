//
//  BirdSuggestion.swift
//  saerok
//
//  Created by HanSeung on 8/1/25.
//


extension Local {
    struct BirdSuggestion: Identifiable {
        var id: ObjectIdentifier { self.bird.id }
        var bird: Local.Bird
        var agreeCount: Int
        var disagreeCount: Int
        var isAgreed: Bool
        var isDisagreed: Bool
        
        static func from(dto: DTO.SuggestionListResponse, existingBirds: [Local.Bird]) -> [Local.BirdSuggestion] {
            return dto.items.compactMap { item in
                return Local.BirdSuggestion(
                    bird: existingBirds.first(where: { $0.id == item.birdId }) ?? .mockData[0],
                    agreeCount: item.agreeCount,
                    disagreeCount: item.disagreeCount,
                    isAgreed: item.isAgreedByMe,
                    isDisagreed: item.isDisagreedByMe
                )
            }
        }
        
        func update(from dto: DTO.ToggleSuggestionResponse) -> BirdSuggestion {
            return .init(
                bird: self.bird,
                agreeCount: dto.agreeCount,
                disagreeCount: dto.disagreeCount,
                isAgreed: dto.isAgreedByMe,
                isDisagreed: dto.isDisagreedByMe
            )
        }
    }
}

extension Local.BirdSuggestion: Equatable {
    static func == (lhs: Local.BirdSuggestion, rhs: Local.BirdSuggestion) -> Bool {
        lhs.id == rhs.id &&
        lhs.agreeCount == rhs.agreeCount &&
        lhs.disagreeCount == rhs.disagreeCount &&
        lhs.isAgreed == rhs.isAgreed &&
        lhs.isDisagreed == rhs.isDisagreed
    }
}

extension Local.BirdSuggestion {
    static let mockData: [Local.BirdSuggestion] = []
}
