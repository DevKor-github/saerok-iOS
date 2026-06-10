//
//  SRNetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

protocol SRNetworkService {
    func performSRRequest<T: Decodable>(_ endpoint: SREndpoint) async throws -> T
    func performSRRequestWithStatus<T: Decodable>(_ endpoint: SREndpoint) async throws -> (T, Int)
    func performKakaoRequest<T: Decodable>(_ endpoint: KakaoEndpoint) async throws -> T
}

final class SRNetworkServiceImpl: SRNetworkService {

    private let apiService: APIService

    /// 토큰 갱신까지 실패해 세션이 만료됐을 때 호출된다.
    /// 앱 부트스트랩에서 `appStore.send(.requireAuthentication)`으로 연결한다.
    var onSessionExpired: (() -> Void)?

    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }

    func performSRRequest<T: Decodable>(_ endpoint: SREndpoint) async throws -> T {
        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.typeError
        }
        do {
            return try await apiService.request(endpoint: endpoint)
        } catch NetworkError.unauthorized {
            try await refreshSessionOrExpire(endpoint)
            return try await apiService.request(endpoint: endpoint)
        }
    }

    func performSRRequestWithStatus<T: Decodable>(_ endpoint: SREndpoint) async throws -> (T, Int) {
        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.typeError
        }
        do {
            return try await apiService.requestWithStatus(endpoint: endpoint)
        } catch NetworkError.unauthorized {
            try await refreshSessionOrExpire(endpoint)
            return try await apiService.requestWithStatus(endpoint: endpoint)
        }
    }

    func performKakaoRequest<T: Decodable>(_ endpoint: KakaoEndpoint) async throws -> T {
        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.unknownError
        }

        return try await apiService.request(endpoint: endpoint)
    }

    /// 401 응답 시 세션을 1회 갱신한 뒤 호출부가 원 요청을 재시도하게 한다.
    ///
    /// - 인증이 필요 없는 엔드포인트(`auth == .none` — refresh 요청 자신 포함)나
    ///   refresh token이 없는 경우(게스트)는 갱신 없이 원래 에러를 그대로 던진다.
    /// - 갱신 요청 자체가 401/403이면 refresh token이 무효한 것이므로
    ///   `onSessionExpired`로 세션 만료를 알린다. 네트워크 오류 등은 만료로 취급하지 않는다.
    private func refreshSessionOrExpire(_ endpoint: SREndpoint) async throws {
        guard endpoint.auth != .none,
              TokenManager.shared.getRefreshToken() != nil
        else { throw NetworkError.unauthorized }

        do {
            try await TokenManager.shared.refreshSession()
        } catch NetworkError.unauthorized, NetworkError.forbidden {
            onSessionExpired?()
            throw NetworkError.unauthorized
        }
    }
}
