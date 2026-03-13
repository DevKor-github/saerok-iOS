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
    
    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }
    
    func performSRRequest<T: Decodable>(_ endpoint: SREndpoint) async throws -> T {
        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.typeError
        }
        return try await apiService.request(endpoint: endpoint)
    }
    
    func performSRRequestWithStatus<T: Decodable>(_ endpoint: SREndpoint) async throws -> (T, Int) {
        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.typeError
        }

        return try await apiService.requestWithStatus(endpoint: endpoint)
    }

    func performKakaoRequest<T: Decodable>(_ endpoint: KakaoEndpoint) async throws -> T {
        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.unknownError
        }

        return try await apiService.request(endpoint: endpoint)
    }
}
