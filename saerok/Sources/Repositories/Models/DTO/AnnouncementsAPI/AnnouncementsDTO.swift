//
//  AnnouncementsDTO.swift
//  saerok
//
//  Created by HanSeung on 2/3/26.
//

import Foundation

extension DTO {
    struct Announcements: Decodable {
        let announcements: [DTO.Announcement]
    }

    struct Announcement: Decodable {
        let id: Int
        let title: String
        let publishedAt: Date
    }
}

