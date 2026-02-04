//
//  AnnouncementDetailDTO.swift
//  saerok
//
//  Created by HanSeung on 2/3/26.
//

import Foundation

extension DTO {
    struct AnnouncementDetail: Decodable {
        let id: Int
        let title: String
        let content: String
        let publishedAt: Date
    }
}
