//
//  SREndpoint.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

/// 새록 백엔드 API 엔드포인트.
///
/// 각 API는 도메인별 `extension SREndpoint`(`SREndpoint+{도메인}.swift`)의
/// **static factory** 하나로 정의한다. 하나의 API에 필요한 모든 속성
/// (path·method·auth·body·response 등)이 한 블록에 모이므로, API를 추가할 때
/// 여러 `switch`를 오가며 수정할 필요가 없다.
struct SREndpoint: Endpoint {

    /// 인증 토큰 부착 정책.
    enum Auth {
        /// 토큰 불필요 (공개 API).
        case none
        /// 항상 토큰 필요.
        case required
        /// 토큰이 있으면 부착, 없으면 게스트로 호출 (로그인 선택 API).
        case ifLoggedIn
    }

    let path: String
    let method: HTTPMethod
    let auth: Auth
    let queryItems: [String: String]?
    let requestBody: Data?
    /// `Content-Type: application/json` 헤더 부착 여부.
    let sendsJSON: Bool
    let expectedResponseType: Decodable.Type

    init(
        path: String,
        method: HTTPMethod = .get,
        auth: Auth = .none,
        query: [String: String]? = nil,
        body: Data? = nil,
        json: Bool = false,
        response: Decodable.Type = EmptyResponse.self
    ) {
        self.path = path
        self.method = method
        self.auth = auth
        self.queryItems = query
        self.requestBody = body
        self.sendsJSON = json
        self.expectedResponseType = response
    }
}

// MARK: - Endpoint conformance

extension SREndpoint {
    var baseURL: String { Bundle.main.baseURL }

    var requiresAuth: Bool {
        switch auth {
        case .none: return false
        case .required: return true
        case .ifLoggedIn: return TokenManager.shared.getAccessToken() != nil
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [:]

        if requiresAuth, let token = TokenManager.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        if sendsJSON {
            headers["Content-Type"] = "application/json"
        }

        return headers.isEmpty ? nil : headers
    }
}

// MARK: - Body / Query 헬퍼

extension SREndpoint {
    /// `Encodable` 모델을 JSON Data로 인코딩.
    static func jsonBody<E: Encodable>(_ value: E) -> Data? {
        try? JSONEncoder().encode(value)
    }

    /// 딕셔너리를 JSON Data로 인코딩 (단일 필드 등 모델이 없는 경우).
    static func jsonBody(_ dict: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: dict)
    }

    /// page·size가 모두 있을 때만 페이지네이션 쿼리를 만든다. (둘 중 하나라도 nil이면 쿼리 없음)
    static func pageQuery(page: Int?, size: Int?) -> [String: String]? {
        guard let page, let size else { return nil }
        return ["page": "\(page)", "size": "\(size)"]
    }

    /// 검색 쿼리. page·size가 모두 있으면 함께 붙이고, 아니면 `q`만 보낸다.
    static func searchQuery(query: String, page: Int?, size: Int?) -> [String: String] {
        guard let page, let size else { return ["q": query] }
        return ["q": query, "page": "\(page)", "size": "\(size)"]
    }
}
