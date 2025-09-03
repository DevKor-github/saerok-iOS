//
//  BirdBookmark.swift
//  saerok
//
//  Created by HanSeung on 6/9/25.
//

extension DTO {
    struct MyBookmarkResponse: Decodable {
        let items: [BookmarkItem]
    }
    
    struct BookmarkItem: Decodable {
        let id: Int
        let birdId: Int
    }
}
