//
//  Analytics.swift
//

import Foundation
import AmplitudeUnified

// MARK: - Screen

enum Screen: String, Codable {
    case unknownDetail = "unknown_detail"
    case identifyHelp = "identify_help"
    case search = "search"
    case confirmModal = "confirm_modal"
}

// MARK: - Event Payload Protocol

protocol EventPayload: Encodable {}

// MARK: - Payload Structs

struct UnknownDetailViewPayload: EventPayload {
    let recordId: String
    let screen: Screen = .unknownDetail
}

struct HelpIdentifyClickPayload: EventPayload {
    let recordId: String
    let screen: Screen = .unknownDetail
    let opinionFlowId: String
    let buttonPosition: String? = nil
}

struct OpinionAddClickPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .identifyHelp
}

struct BirdAutocompleteRequestPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let autocompleteReqId: String
    let screen: Screen = .search
    let queryLength: Int
    let queryTextTruncated: String?
}

struct BirdAutocompleteResponsePayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let autocompleteReqId: String
    let screen: Screen = .search
    let resultCount: Int
    let source: String
}

struct BirdSearchResultClickPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .search
    let birdId: String
    let birdName: String
}

struct OpinionConfirmViewPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .confirmModal
    let birdId: String
    let birdName: String
}

struct OpinionConfirmClickPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .confirmModal
    let birdId: String
    let birdName: String
}

struct OpinionConfirmNoClickPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .confirmModal
    let birdId: String
    let birdName: String
}

struct OpinionCreateSuccessPayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .confirmModal
    let birdId: String
    let birdName: String
    let opinionId: String
}

struct OpinionCreateFailurePayload: EventPayload {
    let recordId: String
    let opinionFlowId: String
    let screen: Screen = .confirmModal
    let birdId: String
    let birdName: String
    let errorCode: String
}

// MARK: - Event Enum

enum AnalyticsEvent {
    case unknownDetailView(UnknownDetailViewPayload)
    case helpIdentifyClick(HelpIdentifyClickPayload)
    case opinionAddClick(OpinionAddClickPayload)
    case birdAutocompleteRequest(BirdAutocompleteRequestPayload)
    case birdAutocompleteResponse(BirdAutocompleteResponsePayload)
    case birdSearchResultClick(BirdSearchResultClickPayload)
    case opinionConfirmView(OpinionConfirmViewPayload)
    case opinionConfirmClick(OpinionConfirmClickPayload)
    case opinionConfirmNoClick(OpinionConfirmClickPayload)
    case opinionCreateSuccess(OpinionCreateSuccessPayload)
    case opinionCreateFailure(OpinionCreateFailurePayload)
}

// MARK: - Flow Manager

final class OpinionFlow {
    let flowId = UUID().uuidString
    private(set) var autocompleteReqId: String?

    func newAutocompleteReqId() -> String {
        let id = UUID().uuidString
        autocompleteReqId = id
        return id
    }
}

// MARK: - Analytics Manager

final class Analytics {

    static let shared = Analytics()

    // 앱 전체에서 공유할 Amplitude 인스턴스
    let amplitude = Amplitude(apiKey:Bundle.main.amplitudeApiKey)

    private init() {}

    // 공통 필드
    private func commonFields() -> [String: Any] {
        [
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "platform": "iOS",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
    }

    // 메인 로깅 함수
    func log(_ event: AnalyticsEvent) {
        var dict = commonFields()

        switch event {
        case .unknownDetailView(let p):
            dict["event"] = "unknown_record_detail_view"
            dict.merge(p.toDict())
            
        case .helpIdentifyClick(let p):
            dict["event"] = "help_identify_click"
            dict.merge(p.toDict())
            
        case .opinionAddClick(let p):
            dict["event"] = "opinion_add_click"
            dict.merge(p.toDict())
            
        case .birdAutocompleteRequest(let p):
            dict["event"] = "bird_autocomplete_request"
            dict.merge(p.toDict())
            
        case .birdAutocompleteResponse(let p):
            dict["event"] = "bird_autocomplete_response"
            dict.merge(p.toDict())
            
        case .birdSearchResultClick(let p):
            dict["event"] = "bird_search_result_click"
            dict.merge(p.toDict())
            
        case .opinionConfirmView(let p):
            dict["event"] = "opinion_confirm_view"
            dict.merge(p.toDict())
            
        case .opinionConfirmClick(let p):
            dict["event"] = "opinion_confirm_click"
            dict.merge(p.toDict())
            
        case .opinionConfirmNoClick(let p):
            dict["event"] = "opinion_confirm_no_click"
            dict.merge(p.toDict())
            
        case .opinionCreateSuccess(let p):
            dict["event"] = "opinion_create_success"
            dict.merge(p.toDict())
            
        case .opinionCreateFailure(let p):
            dict["event"] = "opinion_create_failure"
            dict.merge(p.toDict())
        }
        sendToAmplitude(dict)
    }

    // Amplitude 전송
    private func sendToAmplitude(_ dict: [String: Any]) {
        guard let eventName = dict["event"] as? String else { return }

        var props = dict
        props.removeValue(forKey: "event")

        
//        amplitude.track(
//            eventType: eventName,
//            eventProperties: props
//        )
    }
}

// MARK: - Encodable → Dictionary

extension Encodable {
    func toDict() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }
        return obj
    }
}
