//
//  SREndpoint+Suggestions.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Bird ID Suggestions API

extension SREndpoint {
    static func getSuggestions(collectionId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/bird-id-suggestions",
            auth: .ifLoggedIn,
            response: DTO.SuggestionListResponse.self
        )
    }

    static func suggestBird(collectionId: Int, birdId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/bird-id-suggestions",
            method: .post,
            auth: .required,
            body: jsonBody(["birdId": birdId]),
            json: true,
            response: DTO.SuggestResponse.self
        )
    }

    static func adoptSuggestion(collectionId: Int, birdId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/bird-id-suggestions/\(birdId)/adopt",
            method: .post,
            auth: .required,
            response: DTO.AdoptSuggestionResponse.self
        )
    }

    static func toggleSuggestionAgree(collectionId: Int, birdId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/bird-id-suggestions/\(birdId)/agree",
            method: .post,
            auth: .required,
            response: DTO.ToggleSuggestionResponse.self
        )
    }

    static func toggleSuggestionDisagree(collectionId: Int, birdId: Int) -> SREndpoint {
        SREndpoint(
            path: "collections/\(collectionId)/bird-id-suggestions/\(birdId)/disagree",
            method: .post,
            auth: .required,
            response: DTO.ToggleSuggestionResponse.self
        )
    }

    static func resetSuggestion(collectionId: Int) -> SREndpoint {
        SREndpoint(
            path: "/collections/\(collectionId)/bird-id-suggestions/all",
            method: .delete,
            auth: .required
        )
    }
}
