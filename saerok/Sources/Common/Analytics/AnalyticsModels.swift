//
//  AnalyticsModels.swift
//

import Foundation

// MARK: - Enums

/// 이벤트가 발생한 실제 View 이름.
enum Screen: String, Codable {
    case collection                                              // CollectionView
    case map                                                     // MapView
    case community                                               // CommunityView
    case communityDetailPopular = "community_detail_popular"     // CommunityDetailView(.popular)
    case communityDetailRecent = "community_detail_recent"       // CommunityDetailView(.recent)
    case communityDetailSuggestion = "community_detail_suggestion" // CommunityDetailView(.suggestion)
    case communitySearchResults = "community_search_results"     // CommunitySearchResultsView
    case userSummary = "profile"                            // UserSummaryView
    case collectionDetail = "collection_detail"                  // CollectionDetailView
    case myPage = "my_page"                                      // MyPageView
    case fieldGuide = "field_guide"                              // FieldGuideView
    case deeplink                                                // 알림·딥링크 등 외부 진입
    case unknown
}

enum EntrySource: String, Codable {
    case map
    case `self` = "self_saerok"
    case communityFeed = "home_feed"
    case popular
    case recent
    case suggestion
    case communitySearch = "community_search"
    case userProfile = "profile"
    case notiCenter = "notification"
    case deeplink
    case unknown
}

enum ExitReason: String, Codable {
    case backButton = "back"
    case swipeBack = "swipe"
    case appBackground = "app_background"
    case appOff = "app_off"
    case outsideTap = "outside_tap"
    case navigationTap = "navigation_tap"
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

/// 상세 이탈 직전 마지막으로 취한 행동 (퍼널 2: 댓글 심화)
enum LastAction: String, Codable {
    case commentSubmit = "comment_submit"
    case commentOpen = "comment_open"
    case commentWrite = "comment_write"
    case other
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
    let listLikeCount: Int
    let listCommentCount: Int
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
    let listLikeCount: Int
    let listCommentCount: Int
    let detailTapTs: String
    let detailLoadedTs: String
    let viewtocommentMs: Int
    let commentLoaded: Bool
}

/// 4-1. saerok_comment_submit - 댓글 올리기 버튼 탭 (퍼널 2)
struct SaerokCommentSubmitPayload: EventPayload {
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
    let commentLength: Int
    let isReply: Bool
    let commenttosubmitMs: Int
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
    let listLikeCount: Int
    let listCommentCount: Int
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
    let listLikeCount: Int
    let listCommentCount: Int
    let detailTapTs: String
    let detailLoadedTs: String?
    let viewtoexitMs: Int
    let exitReason: ExitReason
    let hadInteraction: Bool
    let lastAction: LastAction
    let imageLoaded: Bool
    let commentLoaded: Bool
}

// MARK: - Event Enum

enum AnalyticsEvent {
    case saerokDetailTap(SaerokDetailTapPayload)
    case saerokDetailView(SaerokDetailViewPayload)
    case saerokLikeToggle(SaerokLikeTogglePayload)
    case saerokCommentOpen(SaerokCommentOpenPayload)
    case saerokCommentSubmit(SaerokCommentSubmitPayload)
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
