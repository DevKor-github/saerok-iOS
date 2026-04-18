//
//  Analytics.swift
//

import Foundation
import AmplitudeUnified

// MARK: - Analytics Manager

final class Analytics {
    
    static let shared = Analytics()
    
    let amplitude = Amplitude(apiKey: Bundle.main.amplitudeApiKey)
    
    private init() {}
    
    // MARK: - Common Fields
    
    private func commonFields() -> [String: Any] {
        [
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "platform": "iOS",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
    }
    
    private func iso8601String(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
    
    // MARK: - Saerok Detail Funnel Events
    
    func logSaerokDetailTap(flow: DetailViewFlow) {
        let payload = SaerokDetailTapPayload(
            recordId: flow.recordId,
            screen: flow.screen,
            entrySource: flow.entrySource,
            detailViewId: flow.detailViewId,
            detailUiVariant: flow.detailUiVariant,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            platform: "iOS",
            server: .current,
            timestamp: iso8601String(from: flow.detailTapTs),
            isOwnRecord: flow.isOwnRecord,
            listLikeCount: flow.listLikeCount,
            listCommentCount: flow.listCommentCount
        )
        log(.saerokDetailTap(payload))
    }
    
    func logSaerokDetailView(flow: DetailViewFlow) {
        flow.markDetailLoaded()
        
        let payload = SaerokDetailViewPayload(
            recordId: flow.recordId,
            screen: flow.screen,
            entrySource: flow.entrySource,
            detailViewId: flow.detailViewId,
            detailUiVariant: flow.detailUiVariant,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            platform: "iOS",
            server: .current,
            timestamp: iso8601String(from: Date()),
            isOwnRecord: flow.isOwnRecord,
            listLikeCount: flow.listLikeCount,
            listCommentCount: flow.listCommentCount,
            detailTapTs: iso8601String(from: flow.detailTapTs),
            detailLoadedTs: iso8601String(from: flow.detailLoadedTs!),
            loadDurationMs: flow.loadDurationMs(),
            imageLoaded: flow.imageLoaded
        )
        log(.saerokDetailView(payload))
    }
    
    func logSaerokLikeToggle(flow: DetailViewFlow, likeState: LikeState) {
        flow.markHadInteraction()
        
        let payload = SaerokLikeTogglePayload(
            recordId: flow.recordId,
            screen: flow.screen,
            entrySource: flow.entrySource,
            detailViewId: flow.detailViewId,
            detailUiVariant: flow.detailUiVariant,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            platform: "iOS",
            server: .current,
            timestamp: iso8601String(from: Date()),
            isOwnRecord: flow.isOwnRecord,
            detailTapTs: iso8601String(from: flow.detailTapTs),
            detailLoadedTs: iso8601String(from: flow.detailLoadedTs ?? Date()),
            viewtolikeMs: flow.viewToLikeMs(),
            likeState: likeState
        )
        log(.saerokLikeToggle(payload))
    }
    
    func logSaerokCommentOpen(flow: DetailViewFlow, commentLoaded: Bool) {
        flow.markHadInteraction()
        if commentLoaded {
            flow.markCommentLoaded()
        }
        
        let payload = SaerokCommentOpenPayload(
            recordId: flow.recordId,
            screen: flow.screen,
            entrySource: flow.entrySource,
            detailViewId: flow.detailViewId,
            detailUiVariant: flow.detailUiVariant,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            platform: "iOS",
            server: .current,
            timestamp: iso8601String(from: Date()),
            isOwnRecord: flow.isOwnRecord,
            detailTapTs: iso8601String(from: flow.detailTapTs),
            detailLoadedTs: iso8601String(from: flow.detailLoadedTs ?? Date()),
            viewtocommentMs: flow.viewToCommentMs(),
            commentLoaded: commentLoaded
        )
        log(.saerokCommentOpen(payload))
    }
    
    func logSaerokCommentClose(flow: DetailViewFlow) {
        let payload = SaerokCommentClosePayload(
            recordId: flow.recordId,
            screen: flow.screen,
            entrySource: flow.entrySource,
            detailViewId: flow.detailViewId,
            detailUiVariant: flow.detailUiVariant,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            platform: "iOS",
            server: .current,
            timestamp: iso8601String(from: Date()),
            isOwnRecord: flow.isOwnRecord,
            detailTapTs: iso8601String(from: flow.detailTapTs),
            detailLoadedTs: iso8601String(from: flow.detailLoadedTs ?? Date())
        )
        log(.saerokCommentClose(payload))
    }
    
    func logSaerokDetailExit(flow: DetailViewFlow, exitReason: ExitReason) {
        let payload = SaerokDetailExitPayload(
            recordId: flow.recordId,
            screen: flow.screen,
            entrySource: flow.entrySource,
            detailViewId: flow.detailViewId,
            detailUiVariant: flow.detailUiVariant,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            platform: "iOS",
            server: .current,
            timestamp: iso8601String(from: Date()),
            isOwnRecord: flow.isOwnRecord,
            detailTapTs: iso8601String(from: flow.detailTapTs),
            detailLoadedTs: flow.detailLoadedTs != nil ? iso8601String(from: flow.detailLoadedTs!) : nil,
            viewtoexitMs: flow.viewToExitMs(),
            exitReason: exitReason,
            hadInteraction: flow.hadInteraction,
            imageLoaded: flow.imageLoaded,
            commentLoaded: flow.commentLoaded
        )
        log(.saerokDetailExit(payload))
    }
    
    // MARK: - Main Logging Function
    
    private func log(_ event: AnalyticsEvent) {
        var dict = commonFields()
        
        switch event {
        case .saerokDetailTap(let p):
            dict["event"] = "saerok_detail_tap"
            dict.merge(p.toDict())
            
        case .saerokDetailView(let p):
            dict["event"] = "saerok_detail_view"
            dict.merge(p.toDict())
            
        case .saerokLikeToggle(let p):
            dict["event"] = "saerok_like_toggle"
            dict.merge(p.toDict())
            
        case .saerokCommentOpen(let p):
            dict["event"] = "saerok_comment_open"
            dict.merge(p.toDict())
            
        case .saerokCommentClose(let p):
            dict["event"] = "saerok_comment_close"
            dict.merge(p.toDict())
            
        case .saerokDetailExit(let p):
            dict["event"] = "saerok_detail_exit"
            dict.merge(p.toDict())
        }
        
        sendToAmplitude(dict)
    }
    
    // MARK: - Amplitude Transmission
    
    private func sendToAmplitude(_ dict: [String: Any]) {
        guard let eventName = dict["event"] as? String else { return }
        
        var props = dict
        props.removeValue(forKey: "event")
        
         amplitude.track(
             eventType: eventName,
             eventProperties: props
         )
    }
}

// MARK: - Dictionary Merge Extension

extension Dictionary {
    mutating func merge(_ other: [Key: Value]) {
        for (key, value) in other {
            self[key] = value
        }
    }
}

