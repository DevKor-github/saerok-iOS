//
//  SREndpoint+Announcements.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

// MARK: - Announcements API

extension SREndpoint {
    static var announcements: SREndpoint {
        SREndpoint(path: "announcements", response: DTO.Announcements.self)
    }

    static func announcementDetail(id: Int) -> SREndpoint {
        SREndpoint(path: "announcements/\(id)", response: DTO.AnnouncementDetail.self)
    }
}
