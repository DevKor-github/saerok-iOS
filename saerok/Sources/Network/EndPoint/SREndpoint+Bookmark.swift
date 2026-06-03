//
//  SREndpoint+Bookmark.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Bookmark API

extension SREndpoint {
    static var myBookmarks: SREndpoint {
        SREndpoint(path: "birds/bookmarks/", auth: .required, response: DTO.MyBookmarkResponse.self)
    }

    static func toggleBookmark(birdId: Int) -> SREndpoint {
        SREndpoint(
            path: "birds/bookmarks/\(birdId)/toggle",
            method: .post,
            auth: .required,
            response: DTO.ToggleBookmarkResponse.self
        )
    }
}
