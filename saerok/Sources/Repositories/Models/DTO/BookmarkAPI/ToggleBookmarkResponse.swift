//
//  ToggleBookmarkResponse.swift
//  saerok
//
//  Created by HanSeung on 6/5/25.
//


extension DTO {
    struct ToggleBookmarkResponse: Decodable {
        let birdId: Int
        let bookmarked: Bool
    }
}
