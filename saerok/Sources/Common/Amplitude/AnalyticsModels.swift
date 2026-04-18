//
//  AnalyticsModels.swift
//

import Foundation

// MARK: - Enums

enum Screen: String, Codable {
    case collectionMap = "collection_map"
    case collectionList = "collection_list"
    case communityFeed = "community_feed"
    case communityDetail = "community_detail"
    case myPage = "my_page"
    case userProfile = "user_profile"
    case fieldGuide = "field_guide"
    case unknown = "unknown"
}

enum EntrySource: String, Codable {
    case map
    case `self` = "self_saerok"
    case communityFeed = "community_feed"
    case communitySearch = "community_search"
    case userProfile = "user_profile"
    case notiCenter = "notification_center"
    case deeplink
    case unknown
}

enum ExitReason: String, Codable {
    case backButton = "back_button"
    case swipeBack = "swipe_back"
    case outsideTap = "outside_tap"
    case navigationTap = "navigation_tap"
    case appBackground = "app_background"
    case unknown = "unknown"
}

enum DetailUIVariant: String, Codable {
    case variantA = "variant_a"
    case variantB = "variant_b"
}

enum LikeState: String, Codable {
    case on = "on"
    case off = "off"
}

enum ServerEnvironment: String, Codable {
    case development = "개발"
    case production = "운영"
    
    static var current: ServerEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

// MARK: - Event Payload Protocol

protocol EventPayload: Encodable {}

// MARK: - Saerok Detail Funnel Payloads

/// 1. saerok_detail_tap - 사용자가 목록에서 새록 탭
struct SaerokDetailTapPayload: EventPayload {
    let recordId: String
    let screen: Screen
    let entrySource: EntrySource
    let detailViewId: String
    let detailUiVariant: DetailUIVariant
    let appVersion: String
    let platform: String
    let server: ServerEnvironment
    let timestamp: String
    let isOwnRecord: Bool
    let listLikeCount: Int
    let listCommentCount: Int
}

/// 2. saerok_detail_view - 상세화면 완전히 로드됨
struct SaerokDetailViewPayload: EventPayload {
    let recordId: String
    let screen: Screen
    let entrySource: EntrySource
    let detailViewId: String
    let detailUiVariant: DetailUIVariant
    let appVersion: String
    let platform: String
    let server: ServerEnvironment
    let timestamp: String
    let isOwnRecord: Bool
    let listLikeCount: Int
    let listCommentCount: Int
    let detailTapTs: String
    let detailLoadedTs: String
    let loadDurationMs: Int
    let imageLoaded: Bool
}

/// 3. saerok_like_toggle - 좋아요 버튼 클릭
struct SaerokLikeTogglePayload: EventPayload {
    let recordId: String
    let screen: Screen
    let entrySource: EntrySource
    let detailViewId: String
    let detailUiVariant: DetailUIVariant
    let appVersion: String
    let platform: String
    let server: ServerEnvironment
    let timestamp: String
    let isOwnRecord: Bool
    let detailTapTs: String
    let detailLoadedTs: String
    let viewtolikeMs: Int
    let likeState: LikeState
}

/// 4. saerok_comment_open - 댓글 시트 열림
struct SaerokCommentOpenPayload: EventPayload {
    let recordId: String
    let screen: Screen
    let entrySource: EntrySource
    let detailViewId: String
    let detailUiVariant: DetailUIVariant
    let appVersion: String
    let platform: String
    let server: ServerEnvironment
    let timestamp: String
    let isOwnRecord: Bool
    let detailTapTs: String
    let detailLoadedTs: String
    let viewtocommentMs: Int
    let commentLoaded: Bool
}

/// 5. saerok_comment_close - 댓글 시트 닫힘
struct SaerokCommentClosePayload: EventPayload {
    let recordId: String
    let screen: Screen
    let entrySource: EntrySource
    let detailViewId: String
    let detailUiVariant: DetailUIVariant
    let appVersion: String
    let platform: String
    let server: ServerEnvironment
    let timestamp: String
    let isOwnRecord: Bool
    let detailTapTs: String
    let detailLoadedTs: String
}

/// 6. saerok_detail_exit - 상세화면 나감
struct SaerokDetailExitPayload: EventPayload {
    let recordId: String
    let screen: Screen
    let entrySource: EntrySource
    let detailViewId: String
    let detailUiVariant: DetailUIVariant
    let appVersion: String
    let platform: String
    let server: ServerEnvironment
    let timestamp: String
    let isOwnRecord: Bool
    let detailTapTs: String
    let detailLoadedTs: String?
    let viewtoexitMs: Int
    let exitReason: ExitReason
    let hadInteraction: Bool
    let imageLoaded: Bool
    let commentLoaded: Bool
}

// MARK: - Event Enum

enum AnalyticsEvent {
    case saerokDetailTap(SaerokDetailTapPayload)
    case saerokDetailView(SaerokDetailViewPayload)
    case saerokLikeToggle(SaerokLikeTogglePayload)
    case saerokCommentOpen(SaerokCommentOpenPayload)
    case saerokCommentClose(SaerokCommentClosePayload)
    case saerokDetailExit(SaerokDetailExitPayload)
}

// MARK: - Encodable Extension

extension Encodable {
    func toDict() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        guard let data = try? encoder.encode(self),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }
        return obj
    }
}
